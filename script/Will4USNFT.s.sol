// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import { Script } from "forge-std/Script.sol";
// import { Test, console2 } from "forge-std/Test.sol";

import { Will4USNFT } from "../src/Will4USNFT.sol";

/// @notice This script is used to deploy the Will4USNFT contract
/// @dev Use this to run
///      'source .env' if you are using a .env file for your rpc-url
///      'forge script script/Will4USNFT.s.sol:Will4USNFTScript --rpc-url $GOERLI_RPC_URL --broadcast --verify  -vvvv'
contract Will4USNFTScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        // string memory url = vm.rpcUrl("arbitrumGoerli");
        // assertEq(url, "https://arb-goerli.g.alchemy.com/v2/RqTiyvS7OspxaAQUQupKKCTjmf94JL-I");
        vm.startBroadcast(deployerPrivateKey);

        new Will4USNFT(deployerAddress, deployerAddress, deployerAddress, 5);

        // nftContract.awardCampaignItem(deployerAddress, 1);

        vm.stopBroadcast();
    }
}
