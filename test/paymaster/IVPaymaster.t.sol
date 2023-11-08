// SPDX-License-Identifier: GPL-3-0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { Test } from "forge-std/Test.sol";

import { IVPaymaster } from "../../src/paymaster/IVPaymaster.sol";

contract IVPaymasterTest is Test {
    // Test contracts
    address internal constant ARB_GOERLI_SABLIER_ADDRESS = address(0x323B629635b6cFfe2453Aa2869c5957AfF55F445);

    IVPaymaster internal paymaster;
    ISablierV2LockupLinear internal lockupLinear;
    address internal user;

    function setUp() public { }
}
