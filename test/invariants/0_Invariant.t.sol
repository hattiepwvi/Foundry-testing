// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";

// Topics
// - Invariant
// - Difference between fuzz and invariant
// - Failing invariant
// - Passing invariant
// - Stats - runs 测试数量, calls调用的函数数量, reverts 测试失败的次数

contract InvariantIntro {
    // 测试 flag 一直是 false
    bool public flag;

    function func_1() external {}

    function func_2() external {}

    function func_3() external {}

    function func_4() external {}

    function func_5() external {
        flag = true;
    }
}

contract IntroInvariantTest is Test {
    InvariantIntro private target;

    function setUp() public {
        target = new InvariantIntro();
    }

    function invariant_flag_is_always_false() public {
        // 测试会失败，因为第 5 个 flag 是 true
        assertEq(target.flag(), false);
    }
}
