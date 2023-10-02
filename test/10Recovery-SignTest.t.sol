pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/**
 * 1、签名vm.sign()并且验证签名ecrecover()(恢复签名者)： (private key +  msghash) vrs + msghash => signer = public key ?
 *   - solidity: sign the signature offline and then feed that signature into solidity contract
 *   - Foundry:
 *        - set up a private key
 *        - vm.addr to get a public key corresponding to the private key
 *        - message:
 *            - what's message
 *            - hash message
 *        - sign message: vm.sign(private key, hash message)
 */

contract SignTest is Test {
    // private key = 123
    // public key = vm.addr(private key)
    // message = "secret message"
    // message hash = keccak256(message)
    // vm.sign(private key, message hash)
    function testSignature() public {
        uint256 privateKey = 123;
        // Computes the address for a given private key.
        address pubkey = vm.addr(privateKey);

        // Test valid signature
        bytes32 messageHash = keccak256("Signed by Alice");

        // 返回的函数签名分为三个部分：用这三个参数来恢复签名者
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        // 内置函数 ecrecover()
        address signer = ecrecover(messageHash, v, r, s);

        assertEq(signer, pubkey);

        // Test invalid message
        bytes32 invalidMessageHash = keccak256("Not signed by Alice");
        signer = ecrecover(invalidMessageHash, v, r, s);

        assertTrue(signer != pubkey);
    }
}
