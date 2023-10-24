pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import { IVERC20TokenContractFactory } from "../src/IVERC20TokenContractFactory.sol";
import { MockIVToken } from "./mocks/MockIVToken.sol";
import { IVERC20BaseToken } from "../src/IVERC20BaseToken.sol";
import { Errors } from "../src/library/Errors.sol";

contract IVERC20TokenContractFactoryTest is Test {
    IVERC20TokenContractFactory factoryInstance;
    address public deployerAddress;
    IVERC20BaseToken public ivBaseToken;

    uint256 private _nonces;

    function setUp() public {
        deployerAddress = makeAddr("deployerAddress");
        factoryInstance = new IVERC20TokenContractFactory();
        factoryInstance.setDeployer(deployerAddress, true);

        _nonces = 0;
    }

    function test_constructor() public {
        assertTrue(factoryInstance.isDeployer(address(this)));
        assertTrue(factoryInstance.isDeployer(deployerAddress));
    }

    function test_deploy_shit() public {
        address deployedAddress = factoryInstance.deploy(
            deployerAddress, deployerAddress, deployerAddress, "TestToken", "TST"
        );

        assertNotEq(deployedAddress, address(0));
        vm.startPrank(deployerAddress);
        MockIVToken(deployedAddress).mint(deployerAddress, 100e18);
        assertEq(MockIVToken(deployedAddress).balanceOf(deployerAddress), 100e18);
        vm.stopPrank();
    }

    function testRevert_deploy_UNAUTHORIZED() public {
        vm.expectRevert();
        vm.prank(makeAddr("alice"));
        factoryInstance.deploy(
            deployerAddress, deployerAddress, deployerAddress, "TestToken", "TST"
        );
    }

    function test_setDeployer() public {
        address newContractFactoryAddress = makeAddr("bob");

        assertFalse(factoryInstance.isDeployer(newContractFactoryAddress));
        factoryInstance.setDeployer(newContractFactoryAddress, true);
        assertTrue(factoryInstance.isDeployer(newContractFactoryAddress));
    }

    function testRevert_setDeployer_UNAUTHORIZED() public {
        address newContractFactoryAddress = makeAddr("bob");

        vm.expectRevert();
        vm.prank(makeAddr("alice"));
        factoryInstance.setDeployer(newContractFactoryAddress, true);
    }
}
