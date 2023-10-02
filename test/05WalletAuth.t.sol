// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Wallet} from "../src/05Wallet.sol";

contract AuthTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
    }

    function testSetOwner() public {
        // 调用者和owner 是 AuthTest 合约，
        wallet.setOwner(address(1));
        assertEq(wallet.owner(), address(1));
    }

    // 测试错误
    function testFailNotOwner() public {
        // 假装是 address（1）是调用者
        vm.prank(address(1));
        assertEq(wallet.owner(), address(0));
    }

    // 测试多次调用函数,测试错误
    function testFailSetOwnerAgain() public {
        // msg.sender = address(this)
        wallet.setOwner(address(1));

        vm.startPrank(address(1));

        wallet.setOwner(address(1));
        wallet.setOwner(address(1));
        wallet.setOwner(address(1));

        vm.stopPrank();

        // msg.sender = address(this) 所以测试会失败
        wallet.setOwner(address(1));

        wallet.setOwner(address(6));
    }
}
