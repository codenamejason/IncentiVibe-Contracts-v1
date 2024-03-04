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
    function createOccurrence(bytes memory data) external returns (bytes32);
    function updateOccurrence(bytes32 occurrenceId, bytes memory data) external;
    function hostOccurrence(bytes32 occurrenceId, address[] memory) external;
    function recognizeOccurrence(bytes32 occurrenceId, Structs.Metadata memory) external;
    function getStaffMembersForOccurrenceId(bytes32 occurrenceId) external view returns (Structs.Staff[] memory);
    function getOccurrences() external view returns (Structs.Occurrence[] memory);
    function getOccurrenceById(bytes32 occurrenceIdId) external view returns (Structs.Occurrence memory);
}
