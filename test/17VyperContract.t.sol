pragma solidity ^0.8.18;

/**
 * 1、
 * https://github.com/0xKitsune/Foundry-Vyper
 * Install vyper
 *  # virtual env
 * 安装：python3 -m pip install --user virtualenv
 * 初始化： virtualenv -p python3 venv
 * source venv/bin/activate

 * pip3 install vyper==0.3.7
 * 2、步骤： Vyper 合约 => 接口 => 测试
 * 
 * 
 * # Check installation
 * vyper --version
 * Put Vyper contract inside vyper_contracts
 * Declare Solidity interface inside src
 * Copy & paste lib/utils/VyperDeployer.sol
 * Write test
 * forge test --match-path test/Vyper.t.sol --ffi
 * ignore error code
 * ignored_error_codes = ["license", "unused-param", "unused-var"]
 * Deploy
 * source .env
 * forge script script/Token.s.sol:TokenScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
 * Forge geiger
 * forge geiger 
 */

import "forge-std/Test.sol";
import "../lib/utils/VyperDeployer.sol";
import "../src/17IVyperStorage.sol";

// source venv/bin/activate
// forge test --match-path test/Vyper.t.sol --ffi
contract VyperStorageTest is Test {
    VyperDeployer vyperDeployer = new VyperDeployer();

    IVyperStorage vyStorage;

    function setUp() public {
        vyStorage = IVyperStorage(
            vyperDeployer.deployContract("VyperStorage", abi.encode(1234))
        );

        targetContract(address(vyStorage));
    }

    function testGet() public {
        uint256 val = vyStorage.get();
        assertEq(val, 1234);
    }

    function testStore(uint256 val) public {
        vyStorage.store(val);
        assertEq(vyStorage.get(), val);
    }

    function invariant_test() public {
        assertTrue(true);
    }
}
