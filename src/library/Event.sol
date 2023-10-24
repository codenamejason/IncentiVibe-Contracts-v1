// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Metadata } from "./Metadata.sol";

struct Event {
    bytes32 id;
    bytes32 staffId;
    Metadata metadata;
}
