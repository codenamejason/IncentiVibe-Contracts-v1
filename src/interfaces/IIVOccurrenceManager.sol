// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Structs } from "../../src/library/Structs.sol";

/**
 * @title IIVOccurrenceManager
 * @notice Interface for the IVOccurrenceManager contract
 * @dev We use the term occurrence to describe an event, appointment, or any other type of gathering.
 * @author @codenamejason <jax@jaxdoder.xyz>
 */
interface IIVOccurrenceManager {
    function createOccurrence(
        string memory name,
        string memory description,
        uint256 start,
        uint256 end,
        uint256 price,
        address token,
        address[] memory staff,
        Structs.Metadata memory metadata,
        address[] memory attendees
    )
        external
        returns (bytes32);
    function updateOccurrence(
        bytes32 occurrenceId,
        string memory name,
        string memory description,
        uint256 start,
        uint256 end,
        uint256 price,
        address token,
        address[] memory staff,
        Structs.Metadata memory metadata,
        address[] memory attendees
    )
        external;
    function getOccurrence(bytes32 _occurrenceId) external view returns (Structs.Occurrence memory);
    function hostOccurrence(bytes32 occurrenceId, address[] memory) external;
    function recognizeOccurrence(bytes32 occurrenceId, Structs.Metadata memory) external;
    function getStaffMemberByOccurrenceId(bytes32 occurrenceId, address) external view returns (Structs.Staff memory);
    function getStaffMembersForOccurrenceId(bytes32 occurrenceId) external view returns (Structs.Staff[] memory);
    function getOccurrences() external view returns (Structs.Occurrence[] memory);
    function getOccurrenceById(bytes32 occurrenceIdId) external view returns (Structs.Occurrence memory);
}
