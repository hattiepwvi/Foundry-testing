// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ERC20} from "../src/ERC20.sol";

contract Token is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}

/*
 * 1、部署
 * 1）广播：vm.startBroadcast(); 导入环境变量：vm.envUint("DEV_PRIVATE_KEY"); source .env
 * 2）命令：forge script script/Token.s.sol:TokenScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
 */

contract TokenScript is Script {
    function setUp() public {}

    function run() public {
        // 导入环境变量
        uint256 privateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(privateKey);

        console.log("Account", account);

        // 部署前后广播
        vm.startBroadcast(privateKey);

        Token token = new Token("Test Foundry", "TEST_FOUNDRY", 18);
        token.mint(account, 100);

        vm.stopBroadcast();
    }
}
