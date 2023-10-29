pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import { IVERC721TokenContractFactory } from "../src/IVERC721TokenContractFactory.sol";
import { MockIVERC721Token } from "./mocks/MockIVERC721Token.sol";
import { IVERC20BaseToken } from "../src/IVERC20BaseToken.sol";
import { Errors } from "../src/library/Errors.sol";

contract IVERC721TokenContractFactoryTest is Test {
    IVERC721TokenContractFactory factoryInstance;
    address public deployerAddress;
    IVERC20BaseToken public ivBaseToken;

    uint256 private _nonces;

    function setUp() public {
        deployerAddress = makeAddr("deployerAddress");
        factoryInstance = new IVERC721TokenContractFactory();
        factoryInstance.setDeployer(deployerAddress, true);

        _nonces = 0;
    }

    function test_constructor() public {
        assertTrue(factoryInstance.isDeployer(address(this)));
        assertTrue(factoryInstance.isDeployer(deployerAddress));
    }

    function test_deploy_shit() public {
        vm.startPrank(deployerAddress);
        address deployedAddress = factoryInstance.create(
            deployerAddress, deployerAddress, deployerAddress, "TestToken", "TST"
        );

        assertNotEq(deployedAddress, address(0));

        MockIVERC721Token(deployedAddress).awardItem(deployerAddress, 1);
        assertEq(MockIVERC721Token(deployedAddress).balanceOf(deployerAddress), 1);
        vm.stopPrank();
    }

    function testRevert_deploy_UNAUTHORIZED() public {
        vm.expectRevert();
        vm.prank(makeAddr("alice"));
        factoryInstance.create(
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
