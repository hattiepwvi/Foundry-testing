// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Wallet} from "../src/09Transfer-Wallet.sol";

// Examples of deal and hoax
// deal(address, uint) - Set balance of address 设置该地址的余额
// hoax(address, uint) - deal + prank, Sets up a prank and set balance 设置假装某地址的余额

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet{value: 1e18}();
    }

    function _send(uint256 amount) private {
        (bool ok, ) = address(wallet).call{value: amount}("");
        require(ok, "send ETH failed");
    }

    function testEthBalance() public {
        console.log("ETH balance", address(this).balance / 1e18);
    }

    function testSendEth() public {
        uint bal = address(wallet).balance;

        // 设置地址的余额不是累加
        // deal(address, uint) - Set balance of address 设置该地址的余额
        deal(address(1), 100);
        assertEq(address(1).balance, 100);

        deal(address(1), 10);
        assertEq(address(1).balance, 10);

        // hoax(address, uint) - deal + prank, Sets up a prank and set balance 设置假装某地址的余额
        // deal + prank: 假装调用者 address(1) 向 wallet 钱包发送 123 wei;
        deal(address(1), 123);
        vm.prank(address(1));
        _send(123);

        // hoax
        hoax(address(1), 456);
        _send(456);

        assertEq(address(wallet).balance, bal + 123 + 456);
    }
}
