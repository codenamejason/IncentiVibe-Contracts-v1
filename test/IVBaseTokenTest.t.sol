// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { IVBaseToken } from "../src/IVBaseToken.sol";

contract IVBaseTokenTest is Test {
    IVBaseToken public tokenContract;
    address deployerAddress;

    bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        tokenContract = new IVBaseToken(deployerAddress, deployerAddress, deployerAddress);
    }

    function test_deploy() public {
        assertEq(tokenContract.name(), "IVBaseToken", "name should be IVBaseToken");
        assertEq(tokenContract.symbol(), "W4US", "symbol should be W4US");
        assertEq(tokenContract.totalSupply(), 0, "totalSupply should be 0");
        assertEq(tokenContract.balanceOf(deployerAddress), 0, "balanceOf should be 0");
        assertEq(
            tokenContract.hasRole(tokenContract.getRoleAdmin(DEFAULT_ADMIN_ROLE), deployerAddress),
            true,
            "default admin should be deployerAddress"
        );
    }

    function test_mint() public {
        vm.startPrank(deployerAddress);
        // vm.expectEmit(true, true, true, true);
        // emit Transfer(address(0), makeAddr("recipient1"), 10e18);
        tokenContract.mint(makeAddr("recipient1"), 10e18);
        vm.stopPrank();

        assertEq(tokenContract.totalSupply(), 10e18, "totalSupply should be 100");
        assertEq(tokenContract.balanceOf(makeAddr("recipient1")), 10e18, "balanceOf should be 100");
    }

    function test_revert_mint() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();
        tokenContract.mint(makeAddr("recipient1"), 10e18);
        vm.stopPrank();
    }

    function test_pause() public {
        vm.startPrank(deployerAddress);
        // vm.expectEmit(true, true, true, true);
        // emit Paused(deployerAddress);
        tokenContract.pause();
        vm.stopPrank();

        assertEq(tokenContract.paused(), true, "paused should be true");
    }

    function test_revert_pause() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();
        tokenContract.pause();
        vm.stopPrank();
    }

    function test_unpause() public {
        vm.startPrank(deployerAddress);
        // vm.expectEmit(true, true, true, true);
        // emit Unpaused(deployerAddress);
        tokenContract.pause();
        tokenContract.unpause();
        vm.stopPrank();

        assertEq(tokenContract.paused(), false, "paused should be false");
    }

    function test_revert_unpause() public {
        vm.prank(deployerAddress);
        tokenContract.pause();
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();

        tokenContract.unpause();
        vm.stopPrank();
    }

    function test_burn() public {
        vm.startPrank(deployerAddress);
        // vm.expectEmit(true, true, true, true);
        // emit Transfer(deployerAddress, address(0), 10e18);
        tokenContract.mint(deployerAddress, 10e18);
        tokenContract.burn(10e18);
        vm.stopPrank();

        assertEq(tokenContract.totalSupply(), 0, "totalSupply should be 0");
        assertEq(tokenContract.balanceOf(deployerAddress), 0, "balanceOf should be 0");
    }

    function test_revert_burn() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();
        tokenContract.burn(10e18);
        vm.stopPrank();
    }

    function test_revert_transfer() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();
        tokenContract.transfer(makeAddr("recipient1"), 10e18);
        vm.stopPrank();
    }

    function test_revert_transferFrom() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();
        tokenContract.transferFrom(makeAddr("sender1"), makeAddr("recipient1"), 10e18);
        vm.stopPrank();
    }
}
