// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {WETH} from "../../src/WETH.sol";

// Topics
// - handler based testing - test functions under specific conditions
// - target contract
// - target selector

/**
 * 1、在特殊条件下测试函数：降低错误次数
 * 1）Handler 合约：fallback, deposit, withdraw
 * 2) invariant 测试：
 * 3） targetContract：只测试指定的合约
 *     targetSelector: 只测试指定的函数
 */

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    WETH private weth;
    uint256 public wethBalance;
    uint256 public numCalls;

    constructor(WETH _weth) {
        weth = _weth;
    }

    receive() external payable {}

    function sendToFallback(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        // weth合约的 fallback 函数被调用来处理以太币的转移。
        (bool ok, ) = address(weth).call{value: amount}("");
        require(ok, "sendToFallback failed");
    }

    function deposit(uint256 amount) public {
        // 0 < 存储的金额 amount < 余额
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        weth.deposit{value: amount}();
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(address(this)));
        wethBalance -= amount;
        numCalls += 1;

        weth.withdraw(amount);
    }

    // 调用该函数就会 revert 错误： 如果不指定测试的函数的话，这个 fail 函数也会被多次调用，会增加 revert 的次数
    function fail() external {
        revert("fail");
    }
}

contract WETH_Handler_Based_Invariant_Tests is Test {
    WETH public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH();
        handler = new Handler(weth);

        // Send 100 ETH to handler
        deal(address(handler), 100 * 1e18);
        // Set fuzzer to only call the handler
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.withdraw.selector;
        selectors[2] = Handler.sendToFallback.selector;

        // Handler.fail() not called
        // 目标合约 handle, 目标函数 selectors
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
    }

    function invariant_eth_balance() public {
        // 检查weth合约的以太币余额是否大于或等于Handler合约中的wethBalance变量的
        assertGe(address(weth).balance, handler.wethBalance());
        console.log("handler num calls", handler.numCalls());
    }
}
