// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { IVERC721BaseToken } from "../src/IVERC721BaseToken.sol";

contract IVERC721BaseTokenTest is Test {
    address deployerAddress;
    IVERC721BaseToken public tokenContract;

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        tokenContract = new IVERC721BaseToken(
            deployerAddress,
            deployerAddress,
            deployerAddress,
            "TestToken NFT",
            "TST"
        );
    }

    function test_deploy() public {
        assertEq(tokenContract.name(), "TestToken NFT", "name should be TestToken NFT");
        assertEq(tokenContract.symbol(), "TST", "symbol should be TST");
        assertEq(tokenContract.totalSupply(), 0, "totalSupply should be 0");
        assertEq(tokenContract.balanceOf(deployerAddress), 0, "balanceOf should be 0");
    }

    function test_mint() public {
        vm.startPrank(deployerAddress);
        tokenContract.addClass("Volunteer", "Test volunteer class", "https://yourpointer", "", 500000);
        tokenContract.awardCampaignItem(makeAddr("recipient1"), 1);
        vm.stopPrank();

        assertEq(tokenContract.totalSupply(), 1, "totalSupply should be 1");
        assertEq(tokenContract.balanceOf(makeAddr("recipient1")), 1, "balanceOf should be 1");
    }
}