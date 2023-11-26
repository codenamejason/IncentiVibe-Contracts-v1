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
        Structs.Metadata memory metadata
    )
        external
        returns (bytes32);
    function updateOccurrence(
        bytes32 occurenceId,
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
    function getOccurrence(bytes32 _occurenceId) external view returns (Structs.Occurrence memory);
    function hostOccurrence(bytes32 occurenceId, address[] memory) external;
    function recognizeOccurrence(bytes32 occurenceId, Structs.Metadata memory) external;
    function getStaffMemberByOccurrenceId(bytes32 occurenceId, address) external view returns (Structs.Staff memory);
    function getStaffMembersForOccurrenceId(bytes32 occurenceId) external view returns (Structs.Staff[] memory);
    function getOccurrences() external view returns (Structs.Occurrence[] memory);
    function getOccurrenceById(bytes32 occurenceIdId) external view returns (Structs.Occurrence memory);
}
