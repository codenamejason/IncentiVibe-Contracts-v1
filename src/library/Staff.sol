// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Metadata } from "./Metadata.sol";
import { Enums } from "./Enums.sol";

struct Staff {
    // keccak256(abi.encodePacked(_eventId, _member)),
    bytes32 id;
    address member;
    Metadata metadata;
    // member address to their level (the user can have multiple levels and use how they want)
    // uint256[] levels;
    Enums.Status status;
}
