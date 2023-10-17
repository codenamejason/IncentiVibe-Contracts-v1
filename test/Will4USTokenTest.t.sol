// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { Will4USToken } from "../src/Will4USToken.sol";

contract Will4USTokenTest is Test {
    Will4USToken public tokenContract;
    address deployerAddress;

    bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        tokenContract = new Will4USToken(deployerAddress, deployerAddress, deployerAddress);
    }

    function test_deploy() public {
        assertEq(tokenContract.name(), "Will4USToken", "name should be Will4USToken");
        assertEq(tokenContract.symbol(), "W4US", "symbol should be W4US");
        assertEq(tokenContract.totalSupply(), 0, "totalSupply should be 0");
        assertEq(tokenContract.balanceOf(deployerAddress), 0, "balanceOf should be 0");
        assertEq(
            tokenContract.hasRole(tokenContract.getRoleAdmin(DEFAULT_ADMIN_ROLE), deployerAddress),
            true,
            "default admin should be deployerAddress"
        );
    }
}
