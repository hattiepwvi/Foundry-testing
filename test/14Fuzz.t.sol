// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * 1、Fuzz: 自动随机生成函数的参数
 * 1) assume 和 bound 指定模糊测试的范围
 * 2）stat
 *
 * 2、最高有效位（Most Significant Bit，MSB）是二进制数中最左边的位。它是决定数值的符号和大小的关键位。
 *   有符号的二进制数中，最高有效位表示数值的符号。如果最高有效位为0，表示这个数是正数；如果最高有效位为1，表示这个数是负数。
 *   - 最高有效位：从右向左数 0 1 2 3 ...
 *   - 使用了二分查找的方法来确定最高有效位的位置。它从最高位开始，逐步向右移动，检查给定的整数是否大于等于某个特定的值。如果是，则将 x 右移相应的位数，并将 msb 增加相应的值。
 */

import "forge-std/Test.sol";
import {Bit} from "../src/14Fuzz-Bit.sol";

// forge test --match-path test/Fuzz.t.sol

// Topics
// - fuzz
// - assume and bound
// - stats
//   (runs: 256, μ: 18301, ~: 10819)
//   runs - number of tests
//   μ - mean gas used
//   ~ - median gas used

contract FuzzTest is Test {
    Bit public b;

    function setUp() public {
        b = new Bit();
    }

    function mostSignificantBit(uint256 x) private pure returns (uint256) {
        uint256 i = 0;
        // 二分法来找最高有效位：从右到左扫描每一位，只有要1就 i++
        while ((x >>= 1) > 0) {
            i++;
        }
        return i;
    }

    function testMostSignificantBitManual() public {
        // 0 最高有效位是 0， 1 最高有效位 0， 2 最高有效位 1 ..., 最大数的最高有效位是 255
        assertEq(b.mostSignificantBit(0), 0);
        assertEq(b.mostSignificantBit(1), 0);
        assertEq(b.mostSignificantBit(2), 1);
        assertEq(b.mostSignificantBit(4), 2);
        assertEq(b.mostSignificantBit(8), 3);
        assertEq(b.mostSignificantBit(type(uint256).max), 255);
    }

    // Fuzz 测试：自动生成随机的参数
    function testMostSignificantBitFuzz(uint256 x) public {
        // assume - If false, the fuzzer will discard the current fuzz inputs
        //          and start a new fuzz run
        // Skip x = 0
        // vm.assume(x > 0);
        // 测试 x 是不是大于 0
        // assertGt(x, 0);

        // bound(input, min, max) - bound input between min and max
        // Bound
        // 输入的 x 介于 1 和 10 之间
        x = bound(x, 1, 10);
        // assertGe(x, 1);
        // assertLe(x, 10);

        // stats
        // runs - number of tests
        // μ - mean gas used
        // ~ - median gas used
        // assertEq(runs, 256);
        // assertEq(μ, 18301);
        // assertEq(~, 10819);

        uint256 i = b.mostSignificantBit(x);
        assertEq(i, mostSignificantBit(x));
    }
}
