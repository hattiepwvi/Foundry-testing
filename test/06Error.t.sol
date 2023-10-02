// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Error} from "../src/06Error.sol";

/**
 * 1、步骤
 *   vm.expectRevert() 期望抛出什么错误 => 调用函数
 */

contract ErrorTest is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    // 1、测试错误
    // 方法一 testFail()
    function testFail() public {
        err.throwError();
    }

    // 方法二 testRevert() 作用和上面一样
    function testRevert() public {
        vm.expectRevert();
        err.throwError();
    }

    // 方法三 使用require 的方法测试错误
    function testRequireMessage() public {
        vm.expectRevert(bytes("not authorized"));
        err.throwError();
    }

    // 2、测试自定义错误
    function testCustomError() public {
        vm.expectRevert(Error.NotAuthorized.selector);
        err.throwCustomError();
    }

    // 3、 标记断言（指出是哪个断言失败了）: test 1, test 2 ...
    function testErrorLabel() public {
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(1), "test 3");
        assertEq(uint256(1), uint256(2), "test 4");
        assertEq(uint256(1), uint256(1), "test 5");
    }
}
