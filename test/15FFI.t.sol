// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * 1、FFI测试： Form function interface 外部函数接口
 * 1）不同编程语言之间的交互：比如 Linux, Python 等
 * 2) Linux 命令：cat 文件名：将文件 ffi_test.txt 的内容打印到终端上；比如，cat ffi_test.txt
 * 3) 测试命令： forge test --match-path test/15FFI.t.sol --ffi -vvv
 */

import "forge-std/Test.sol";
import "forge-std/console.sol";

// forge test --match-path test/FFI.t.sol --ffi -vvvv

contract FFITest is Test {
    function testFFI() public {
        string[] memory cmds = new string[](2);
        // 执行ffi测试：传入命令 + 参数
        cmds[0] = "cat";
        cmds[1] = "ffi_test.txt";
        bytes memory res = vm.ffi(cmds);
        console.log(string(res));
    }
}
