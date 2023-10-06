// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";

import {Will4USNFT} from "../src/Will4USNFT.sol";

/// @notice This script is used to create test data for the Allo V2 contracts
/// @dev Register recipients and set their status ~
/// Use this to run
///      'source .env' if you are using a .env file for your rpc-url
///      'forge script script/Will4USNFT.s.sol:Will4USNFTScript --rpc-url $GOERLI_RPC_URL --broadcast  -vvvv'
contract Will4USNFTScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Will4USNFT nftContract = new Will4USNFT();

        vm.stopBroadcast();
    }
}
