// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Auction} from "../src/08Time-Auction.sol";

/**
 * 1、 时间测试
 *   vm.warp - set block.timestamp to future timestamp
 *   vm.roll - set block.number 或 timestamp
 *   skip - increment current timestamp
 *   rewind - decrement current timestamp
 */

contract TimeTest is Test {
    Auction public auction;
    uint256 private startAt;

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    // 测试 bid 失败 （时间不到）
    function testBidFailsBeforeStartTime() public {
        // 期望调用这个函数会失败
        vm.expectRevert(bytes("cannot bid"));
        auction.bid();
    }

    // 测试 bid 成功 （时间正好）
    function testBid() public {
        // 设置 timestamp
        vm.warp(startAt + 1 days);
        auction.bid();
    }

    // 测试 bid 失败 （时间过了）
    function testBidFailsAfterEndTime() public {
        vm.expectRevert(bytes("cannot bid"));
        vm.warp(startAt + 2 days);
        auction.bid();
    }

    function testTimestamp() public {
        uint t = block.timestamp;
        // skip - increment current timestamp
        skip(100);
        assertEq(block.timestamp, t + 100);
        // rewind - decrement current timestamp
        rewind(10);
        assertEq(block.timestamp, t + 100 - 10);
    }

    function testBlockNumber() public {
        // vm.roll - set block.number 或 timestamp
        uint b = block.number;
        vm.roll(999);
        assertEq(block.number, 999);
    }
}
