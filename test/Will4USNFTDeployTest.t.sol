// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { Will4USNFT } from "../src/Will4USNFT.sol";

/// @notice This contract is used to test the Will4USNFT contract
contract Will4USNFTDeployTest is Test {
    Will4USNFT public nftContract;
    address deployerAddress;

    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(
        address indexed sender, uint256 indexed classId, uint256 indexed tokenId, string tokenURI
    );
    event CampaignMemberAdded(address indexed member);
    event CampaignMemberRemoved(address indexed member);
    event ClassAdded(uint256 indexed classId, string metadata);

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        nftContract = new Will4USNFT(deployerAddress, 5);
        string memory url = vm.rpcUrl("arbitrumGoerli");
        assertEq(url, "https://arb-goerli.g.alchemy.com/v2/RqTiyvS7OspxaAQUQupKKCTjmf94JL-I");
    }

    // todo: test that the contract is deployed with the correct parameters
    function test_deploy() public {
        assertEq(nftContract.maxMintablePerClass(), 5, "maxMintablePerClass should be 5");
        assertEq(nftContract.totalClassesSupply(), 0, "totalSupply should be 0");
        assertEq(nftContract.balanceOf(deployerAddress), 0, "balanceOf should be 0");
        assertEq(nftContract.owner(), deployerAddress, "owner should be deployerAddress");
    }
}
