// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * 1、GaslessTokenTransfer
 * 1）方法一： A 有 DAI 没有 ether 支付 gas ，B 有 ether：A 授权 B 使用自己的 10 个 Dai, B 用 ether 支付 gas
 * 2）方法二： A 和 B 都没有 ether 支付 gas， C 有 ether 支付 gas : A 授权 B 使用自己的 10 个 Dai, A 给 1 个 Dai 给 C 支付 gas
 *
 * 2、签名和验证签名的案例：prove（签名和验证签名） + send 转账 + check balance
 * 1） permit 函数的 hash msg: bytes32 permitHash = _getPermitHash(sender, address(gasless), AMOUNT + FEE, token.nonces(sender), deadline);
 *       - abi.encodePacked 函数来将多个参数打包成一个字节数组，然后将其作为输入传递给 keccak256 函数。
 *       - 在打包参数之前，函数还使用了一些特殊的前缀，包括 "\x19\x01" 和 token.DOMAIN_SEPARATOR()。这些前缀用于确保生成的哈希值与其他许可的哈希值不冲突，并提供额外的安全性。
 * 2)  合约里的转账函数： gasless.send(address(token), sender, receiver, AMOUNT, FEE, deadline, v, r, s);
 *
 */

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/ERC20Permit.sol";
import "../src/11Transfer-GaslessTokenTransfer.sol";

contract GaslessTokenTransferTest is Test {
    ERC20Permit private token;
    GaslessTokenTransfer private gasless;

    uint256 constant SENDER_PRIVATE_KEY = 123;
    address sender;
    address receiver;
    uint256 constant AMOUNT = 1000;
    uint256 constant FEE = 10;

    function setUp() public {
        // 用私钥创造公钥; sender 签署 approve 消息
        sender = vm.addr(SENDER_PRIVATE_KEY);
        receiver = address(2);

        token = new ERC20Permit("Test", "TEST", 18);
        token.mint(sender, AMOUNT + FEE);

        // 部署 GaslessTokenTransfer 合约
        gasless = new GaslessTokenTransfer();
    }

    function testValidSig() public {
        uint256 deadline = block.timestamp + 60;

        // Sender - prepare permit signature
        // 获取 nounce: token.nonces(sender)
        bytes32 permitHash = _getPermitHash(
            sender,
            address(gasless),
            AMOUNT + FEE,
            token.nonces(sender),
            deadline
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            SENDER_PRIVATE_KEY,
            permitHash
        );

        // Execute transfer
        gasless.send(
            address(token),
            sender,
            receiver,
            AMOUNT,
            FEE,
            deadline,
            v,
            r,
            s
        );

        // Check balances
        assertEq(token.balanceOf(sender), 0, "sender balance");
        assertEq(token.balanceOf(receiver), AMOUNT, "receiver balance");
        assertEq(token.balanceOf(address(this)), FEE, "fee");
    }

    // 创建一个 private 函数
    function _getPermitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }
}
