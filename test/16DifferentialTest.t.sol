pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {exp} from "../src/16Exp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * 1、差异测试
 * 1) 对比测试 exp.py 和 Exp.sol 两个指数函数脚本的计算结果
 * 2）python
 *   - 安装python 的包：pip install eth_abi
 *   - 命令：python exp.py 18446744073709551616  ----- 2 的 64次方 （在 Exp.sol 里被视为 1），所以运行命令后得到的是e的1次方（2.718 和 它的 hash 值）
 *     - Solidity 使用固定点数表示法，其中小数点位于 64 位之后。将 2 的 64 次方视为 1 是为了表示最小的非零值。
 */
// Foundry 将强制此 fuzz 测试 100 次
// FOUNDRY_FUZZ_RUNS=100 forge test --match-path test/DifferentialTest.t.sol --ffi -vvv

contract DifferentialTest is Test {
    using Strings for uint256;

    function setUp() public {}

    // 调用外部 python 脚本
    function ffi_exp(int128 x) private returns (int128) {
        require(x >= 0, "x < 0");

        string[] memory inputs = new string[](3);
        inputs[0] = "python";
        inputs[1] = "exp.py";
        inputs[2] = uint256(int256(x)).toString();

        bytes memory res = vm.ffi(inputs);
        // console.log(string(res));

        int128 y = abi.decode(res, (int128));

        return y;
    }

    function test_exp(int128 x) public {
        // 2**64 = 1 (64.64 bit number)
        vm.assume(x >= 2 ** 64);
        vm.assume(x <= 20 * 2 ** 64);

        int128 y0 = ffi_exp(x);
        int128 y1 = exp(x);

        // Check |y0 - y1| <= 1
        uint256 DELTA = 2 ** 64;
        assertApproxEqAbs(uint256(int256(y0)), uint256(int256(y1)), DELTA);
    }
}
