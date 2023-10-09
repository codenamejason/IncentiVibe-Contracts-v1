// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Will4USNFT} from "../src/Will4USNFT.sol";

/// @notice This contract is used to test the Will4USNFT contract
contract Will4USNFTTest is Test {
    Will4USNFT public nftContract;
    address deployerAddress;

    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(address indexed sender, uint256 indexed tokenId, string tokenURI);
    event CampaignMemberAdded(address indexed member);
    event CampaignMemberRemoved(address indexed member);
    event ClassAdded(uint256 indexed classId, string metadata);

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        nftContract = new Will4USNFT(deployerAddress);

        vm.startPrank(deployerAddress);
        nftContract.addCampaignMember(deployerAddress);
        nftContract.addClass("name", "description", "imagePointer", "https://a_new_pointer_to_json_object.io", 1e7);
        nftContract.awardCampaignItem(makeAddr("recipient1"), "https://placeholder.com/1", 1);
        vm.stopPrank();
    }

    function test_awardCampaignItem() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit ItemAwarded(2, makeAddr("recipient1"), 1);
        uint256 tokenId1 = nftContract.awardCampaignItem(makeAddr("recipient1"), "https://placeholder.com/1", 1);

        // mint a second token

        vm.expectEmit(true, true, true, true);
        emit ItemAwarded(3, makeAddr("recipient1"), 1);
        uint256 tokenId2 = nftContract.awardCampaignItem(makeAddr("recipient1"), "https://placeholder.com/1", 1);

        vm.stopPrank();
        assertEq(tokenId1, 2, "Token Id should be 2");
        assertEq(tokenId2, 3, "Token Id should be 3");
    }

    function test_updateTokenMetadata() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit TokenMetadataUpdated(deployerAddress, 1, "https://placeholder.com/1");
        nftContract.updateTokenMetadata(1, "https://placeholder.com/1");

        vm.stopPrank();
        assertEq(nftContract.tokenURI(1), "https://placeholder.com/1", "Token URI should be https://placeholder.com/1");
    }

    function test_addCampaignMember() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit CampaignMemberAdded(makeAddr("member1"));
        nftContract.addCampaignMember(makeAddr("member1"));

        vm.stopPrank();
        assertEq(nftContract.campaignMembers(makeAddr("member1")), true, "Member should be added");
    }

    function test_removeCampaignMember() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit CampaignMemberRemoved(makeAddr("member1"));
        nftContract.removeCampaignMember(makeAddr("member1"));

        vm.stopPrank();
        assertEq(nftContract.campaignMembers(makeAddr("member1")), false, "Member should be removed");
    }

    function test_addClass() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit ClassAdded(2, "https://a_new_pointer_to_json_object.io");
        nftContract.addClass("name2", "description", "imagePointer", "https://a_new_pointer_to_json_object.io", 1e7);

        vm.stopPrank();
        assertEq(nftContract.getClassById(2).name, "name2", "Class name should be name");
    }
}
