// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

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
        // uint256[] levels;
        Enums.Status status;
    }

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
}
