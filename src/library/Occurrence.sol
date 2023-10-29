// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Metadata } from "./Metadata.sol";
import { Enums } from "./Enums.sol";

struct Occurrence {
    // keccak256(abi.encodePacked(_name, _start, _end))
    bytes32 id;
    address creator;
    string name;
    string description;
    uint256 start;
    uint256 end;
    uint256 price;
    address token;
    Enums.Status status;
    address[] staff;
    Metadata metadata;
}
