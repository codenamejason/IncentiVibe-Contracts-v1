// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Enums } from "./Enums.sol";

library Structs {
    struct Metadata {
        /// @notice Protocol ID corresponding to a specific protocol (currently using IPFS = 1)
        uint256 protocol;
        /// @notice Pointer (hash) to fetch metadata for the specified protocol
        string pointer;
    }

    struct Staff {
        // keccak256(abi.encodePacked(_eventId, _member)),
        bytes32 id;
        address member;
        Metadata metadata;
        // member address to their level (the user can have multiple levels and use how they want)
        // uint256[] class;
        Enums.Status status;
    }

    struct Attendee {
        bytes32 id;
        address attendee;
        Metadata metadata;
        Enums.Status status;
    }

    struct Community {
        // keccak256(abi.encodePacked(_name, _creator))
        bytes32 id;
        address creator;
        string name;
        string description;
        string imagePointer;
        Metadata metadata;
        address[] staff;
        bytes32[] occurrences;
        Enums.Status status;
    }

    struct Occurrence {
        // keccak256(abi.encodePacked(_name, _creator))
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
        address[] attendees;
    }
    // Attendee[] attendees;

    struct Class {
        uint256 id;
        uint256 supply; // total supply of this class? do we want this?
        uint256 minted;
        string name;
        string description;
        string imagePointer;
        string metadata; // this is a pointer to json object that contains the metadata for this class
    }
}
