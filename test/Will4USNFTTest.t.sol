// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";
import { Will4USNFT } from "../src/Will4USNFT.sol";

/// @notice This contract is used to test the Will4USNFT contract
contract Will4USNFTTest is Test {
    bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    Will4USNFT public nftContract;
    address deployerAddress;

    error InvalidTokenId(uint256 tokenId);
    error MaxMintablePerClassReached(address recipient, uint256 classId, uint256 maxMintable);
    error AlreadyRedeemed(address redeemer, uint256 tokenId);
    error Unauthorized(address sender);
    error NewSupplyTooLow(uint256 minted, uint256 supply);

    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(
        address indexed sender, uint256 indexed classId, uint256 indexed tokenId, string tokenURI
    );
    event CampaignMemberAdded(address indexed member);
    event CampaignMemberRemoved(address indexed member);
    event ClassAdded(uint256 indexed classId, string metadata);
    event Redeemed(uint256 indexed eventId, uint256 indexed tokenId, uint256 indexed classId);
    event RoleGranted(bytes32 indexed role, address indexed account, address sender);

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        nftContract = new Will4USNFT(deployerAddress, deployerAddress, deployerAddress, 5);

        vm.startPrank(deployerAddress);
        nftContract.addCampaignMember(deployerAddress);
        nftContract.addClass(
            "name", "description", "imagePointer", "https://a_new_pointer_to_json_object.io", 1e7
        );
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        vm.stopPrank();
    }

    function test_awardCampaignItem() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit ItemAwarded(2, makeAddr("recipient1"), 1);
        uint256 tokenId1 = nftContract.awardCampaignItem(makeAddr("recipient1"), 1);

        // mint a second token
        vm.expectEmit(true, true, true, true);
        emit ItemAwarded(3, makeAddr("recipient1"), 1);
        uint256 tokenId2 = nftContract.awardCampaignItem(makeAddr("recipient1"), 1);

        vm.stopPrank();
        assertEq(tokenId1, 2, "Token Id should be 2");
        assertEq(tokenId2, 3, "Token Id should be 3");
    }

    function test_revert_awardCampaignItem_maxMintablePerClass() public {
        vm.startPrank(deployerAddress);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        vm.expectRevert();
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);

        vm.stopPrank();
    }

    function test_batchAwardCampaignItem() public {
        vm.startPrank(deployerAddress);
        address[] memory recipients = new address[](2);
        recipients[0] = makeAddr("recipient1");
        recipients[1] = makeAddr("recipient2");
        string[] memory tokenURIs = new string[](2);
        uint256[] memory classIds = new uint256[](2);
        classIds[0] = 1;
        classIds[1] = 1;

        nftContract.batchAwardCampaignItem(recipients, classIds);

        vm.stopPrank();
    }

    function test_updateTokenMetadata() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit TokenMetadataUpdated(
            deployerAddress,
            1,
            1,
            "https://pharo.mypinata.cloud/ipfs/QmSnzdnhtCuJ6yztHmtYFT7eU2hFF17QNM6rsNohFn6csg/2/1.json"
        );
        nftContract.updateTokenMetadata(1, 1, "2/1.json");

        vm.stopPrank();
        assertEq(
            nftContract.tokenURI(1),
            "https://pharo.mypinata.cloud/ipfs/QmSnzdnhtCuJ6yztHmtYFT7eU2hFF17QNM6rsNohFn6csg/2/1.json"
        );
    }

    function test_addCampaignMember() public {
        vm.startPrank(deployerAddress);
        nftContract.addCampaignMember(makeAddr("member1"));

        vm.stopPrank();
        assertEq(
            nftContract.hasRole(MINTER_ROLE, makeAddr("member1")),
            true,
            "Member should have MINTER_ROLE"
        );
    }

    function test_removeCampaignMember() public {
        vm.startPrank(deployerAddress);

        nftContract.removeCampaignMember(makeAddr("member1"));
        vm.stopPrank();
        assertEq(
            nftContract.hasRole(MINTER_ROLE, makeAddr("member1")),
            false,
            "Member should NOT have MINTER_ROLE"
        );
    }

    function test_redeem() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit Redeemed(1, 1, 1);

        nftContract.redeem(1, 1);
    }

    function test_revert_redeem_AlreadyRedeemed() public {
        vm.startPrank(deployerAddress);
        nftContract.redeem(1, 1);
        vm.expectRevert();

        nftContract.redeem(1, 1);
        vm.stopPrank();
    }

    function test_revert_redeem_Unauthorized() public {
        vm.startPrank(makeAddr("chad"));
        vm.expectRevert();

        nftContract.redeem(1, 1);
        vm.stopPrank();
    }

    function test_addClass() public {
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, true, true, true);
        emit ClassAdded(2, "https://a_new_pointer_to_json_object.io");
        nftContract.addClass(
            "name2", "description", "imagePointer", "https://a_new_pointer_to_json_object.io", 1e7
        );

        vm.stopPrank();
        (
            uint256 id,
            uint256 supply,
            uint256 minted,
            string memory name,
            string memory description,
            string memory imagePointer,
            string memory metadataPointer
        ) = nftContract.classes(2);
        assertEq(name, "name2", "Class name should be name");
    }

    function test_revert_addClass_Unauthorized() public {
        vm.prank(makeAddr("chad"));
        vm.expectRevert();
        nftContract.addClass(
            "name2", "description", "imagePointer", "https://a_new_pointer_to_json_object.io", 1e7
        );
    }

    function test_getTotalSupplyForClass() public {
        assertEq(nftContract.getTotalSupplyForClass(1), 1e7, "Total supply should be 1e7");
    }

    function test_setClassTokenSupply() public {
        vm.prank(deployerAddress);
        nftContract.setClassTokenSupply(1, 1e10);

        (, uint256 supply,,,,,) = nftContract.classes(1);
        assertEq(supply, 1e10, "Total supply should be 1e10");
    }

    function test_revert_setClassTokenSupply_NewSupplyTooLow() public {
        vm.startPrank(deployerAddress);
        nftContract.setClassTokenSupply(1, 10);
        nftContract.awardCampaignItem(makeAddr("recipient1"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient2"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient3"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient4"), 1);
        nftContract.awardCampaignItem(makeAddr("recipient5"), 1);
        vm.expectRevert();
        nftContract.setClassTokenSupply(1, 5);
        vm.stopPrank();
    }

    function test_revert_setClassTokenSupply_Unauthorized() public {
        vm.prank(makeAddr("chad"));
        vm.expectRevert();
        nftContract.setClassTokenSupply(1, 1e10);
    }

    function test_getTotalSupplyForAllClasses() public {
        assertEq(nftContract.getTotalSupplyForAllClasses(), 1e7, "Total supply should be 1e7");
    }

    function test_setMaxMintablePerClass() public {
        vm.prank(deployerAddress);
        nftContract.setMaxMintablePerClass(10);

        assertEq(nftContract.maxMintablePerClass(), 10, "Total supply should be 1e10");
    }

    function test_revert_setMaxMintablePerClass_Unauthorized() public {
        vm.prank(makeAddr("chad"));
        vm.expectRevert();
        nftContract.setMaxMintablePerClass(10);
    }
}
