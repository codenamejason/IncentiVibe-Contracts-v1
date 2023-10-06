// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Will4USNFT} from "../src/Will4USNFT.sol";

contract Will4USNFTTest is Test {
    Will4USNFT public nftContract;

    function setUp() public {
        address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        nftContract = new Will4USNFT(deployerAddress);
    }

    function test_Mint() public {}

    function test_UpdateMetadata() public {}
}
