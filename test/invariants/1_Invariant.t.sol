// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {WETH} from "../../src/WETH.sol";

// https://book.getfoundry.sh/forge/invariant-testing?highlight=targetSelector#invariant-targets
// https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw

// NOTE: open testing - randomly call all public functions
contract WETH_Open_Invariant_Tests is Test {
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    receive() external payable {}

    // NOTE: - calls = runs x depth, (runs, calls, reverts)
    function invariant_totalSupply_is_always_zero() public {
        // 如果 Foundry 调用了 WETH 里面的 deposit 函数，那么总供给量就不会是 0，所以会测试失败，所以余额不会总是 0
        // 调用 withdraw 函数时余额不够也会 fail
        // 调用 transfer 函数时如果 msg.sender 的余额不够也会 fail
        assertEq(0, weth.totalSupply());
    }
}
