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

    function test_addCampaignMember(address _member) public {}

    function test_removeCampaignMember(address _member) public {}
    
    function test_awardCampaignItem(address _recipient, string memory _tokenURI, uint256 _classId) public {}

    function test_addClass(string memory _name, string memory _description, string memory _imagePointer, uint256 _supply) public {}

    function test_updateTokenMetadata(uint256 _tokenId, string memory _tokenURI) public {}

    function test_getClassById(uint256 _id) public {}

    function test__mintCampaingnItem(address _recipient, string memory _tokenURI, uint256 _classId) public {}

    function test_supportsInterface(bytes4 interfaceId) public {}

    function test_tokenURI(uint256 tokenId) public {}
}
