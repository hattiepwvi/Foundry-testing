// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * 1、模拟在主网交易 100 DAI
 */

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/interfaces/IERC20.sol";

contract ForkTest is Test {
    IERC20 public dai;

    function setUp() public {
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function testDeposit() public {
        address alice = address(123);

        uint256 balBefore = dai.balanceOf(alice);
        console.log("balance before", balBefore);

        uint256 totalBefore = dai.totalSupply();
        console.log("total supply before", totalBefore / 1e18);

        // token, account, amount, adjust total supply
        // true 是调整 total supply 也增加 1e6 * 1e18
        deal(address(dai), alice, 1e6 * 1e18, true);

        uint256 balAfter = dai.balanceOf(alice);
        console.log("balance after", balAfter / 1e18);

        uint256 totalAfter = dai.totalSupply();
        console.log("total supply after", totalAfter / 1e18);
    }
}
