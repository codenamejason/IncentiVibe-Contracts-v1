// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Will4USNFT} from "../src/Will4USNFT.sol";

/// @notice This contract is used to test the Will4USNFT contract
contract Will4USNFTTest is Test {
    Will4USNFT public nftContract;
    address deployerAddress;

    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        nftContract = new Will4USNFT(deployerAddress);
    }

    function test_awardCampaignItem() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit ItemAwarded(1, makeAddr("recipient1"), 1);
        uint256 tokenId = nftContract.awardCampaignItem(makeAddr("recipient1"), "https://placeholder.com/1", 1);
        vm.stopPrank();

        assertEq(tokenId, 1, "Token Id should be 1");
    }

    function test_UpdateMetadata() public {}
}
