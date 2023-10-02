// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

/**
 * 1、简介：Topic 存储/每个事件最多3个indexed;value 不带 indexed 关键字，会存储在事件的 data  部分
 *   1）步骤：vm.expectEmit()检查什么 => 期望调用函数后 emit 的事件 => 调用函数
 *       - tell Foundry which data to check
 *       - Emit the expect event
 *       - call the function that should emit the event *
 */

import "forge-std/Test.sol";
import {Event} from "../src/07Event.sol";

contract EventTest is Test {
    Event public e;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        e = new Event();
    }

    function testEmitTransferEvent() public {
        // 1）tell Foundry which data to check
        // function expectEmit(
        //     bool checkTopic1,
        //     bool checkTopic2,
        //     bool checkTopic3,
        //     bool checkData
        // ) external;
        // check index 1, index 2 and data
        // 告诉 foundry 不用 check 第三个参数
        vm.expectEmit(true, true, false, true);

        // 2）Emit the expect event
        // 调用步骤 3 的函数的时候，期望 emit 下面这个事件
        emit Transfer(address(this), address(123), 456);

        // 3）call the function that should emit the event
        e.transfer(address(this), address(123), 456);

        // Check index 1
        vm.expectEmit(true, false, false, false);
        emit Transfer(address(this), address(123), 456);
        e.transfer(address(this), address(777), 999);
    }

    function testEmitManyTransferEvent() public {
        address[] memory to = new address[](2);
        to[0] = address(123);
        to[1] = address(456);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 777;
        amounts[1] = 888;

        for (uint i; i < to.length; i++) {
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amounts[i]);
        }
        e.transferMany(address(this), to, amounts);

        // 1) tell Foundry which data to check
        // 2) Emit the expect event
        // 3) call the function that should emit the event
    }
}
