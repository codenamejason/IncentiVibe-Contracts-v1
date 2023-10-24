// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Metadata } from "./Metadata.sol";

enum StaffStatus {
    Pending,
    Active,
    Inactive
}

struct Staff {
    bytes32 id;
    address member;
    Metadata metadata;
    // member address to their level (the user can have multiple levels and use how they want)
    mapping(address => uint256[]) levels;
    StaffStatus status;
}
