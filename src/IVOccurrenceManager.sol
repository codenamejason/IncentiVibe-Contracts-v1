// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { IVStaffManager } from "./IVStaffManager.sol";
import { IIVOccurrenceManager } from "./interfaces/IIVOccurrenceManager.sol";
import { Enums } from "./library/Enums.sol";
import { Structs } from "./library/Structs.sol";
import { Errors } from "./library/Errors.sol";
import { Events } from "./library/Events.sol";

// import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title IVOccurrenceManager
 * @notice The IVOccurrenceManager contract is responsible for managing the occurrences
 * @dev We use the term occurrence to describe an event, appointment, or any other type of gathering.
 * @author @codenamejason <jax@jaxdoder.xyz>
 */
contract IVOccurrenceManager is IIVOccurrenceManager, IVStaffManager {
    /**
     * Storage
     */
    mapping(bytes32 => Structs.Occurrence) public occurrences;
    mapping(bytes32 => address[]) public attendeesAtEvent;
    mapping(bytes32 => mapping(bytes32 => Structs.Attendee)) public attendeeAtEvent;
    uint256 private _occurrenceCount;

    IVStaffManager public staffManager;

    /**
     * Modifier
     */
    modifier onlyCreator(bytes32 _occurrenceId, address _creator) {
        if (occurrences[_occurrenceId].creator != _creator) {
            revert Errors.NotCreator(_creator);
        }
        _;
    }

    modifier occurrenceExists(bytes32 _occurrenceIdId) {
        if (occurrences[_occurrenceIdId].id != _occurrenceIdId) {
            revert Errors.OccurrenceDoesNotExist(_occurrenceIdId);
        }
        _;
    }

    constructor(address _defaultAdmin) IVStaffManager(_defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /**
     * Views
     */

    /**
     * @notice Get a staff member
     *
     * @param _occurrenceId The ID of the occurrence
     * @param _member The address of the staff member
     * @return staffMember The staff member
     */
    function getStaffMemberByOccurrenceId(
        bytes32 _occurrenceId,
        address _member
    )
        external
        view
        occurrenceExists(_occurrenceId)
        returns (Structs.Staff memory)
    {
        return staff[_occurrenceId][_member];
    }

    /**
     * @notice Get staff members for an occurrence
     *
     * @param _occurrenceId The ID of the occurrence
     * @return staffMembers The staff members
     */
    function getStaffMembersForOccurrenceId(bytes32 _occurrenceId)
        external
        view
        occurrenceExists(_occurrenceId)
        returns (Structs.Staff[] memory)
    {
        Structs.Occurrence memory occurrence = occurrences[_occurrenceId];
        Structs.Staff[] memory _staff = new Structs.Staff[](occurrence.staff.length);

        for (uint256 i = 0; i < occurrence.staff.length; i++) {
            _staff[i] = staff[_occurrenceId][occurrence.staff[i]];
        }

        return _staff;
    }

    function getAttendeesByOccurrenceId(bytes32 _occurrenceId) external view returns (address[] memory) {
        return attendeesAtEvent[_occurrenceId];
    }

    function getOccurrences() external view returns (Structs.Occurrence[] memory) {
        Structs.Occurrence[] memory _occurrences = new Structs.Occurrence[](_occurrenceCount);

        for (uint256 i = 0; i < _occurrenceCount; i++) {
            // FIXME: this is not the correct way to do this
            _occurrences[i] = occurrences[keccak256(abi.encodePacked(i))];
        }

        return _occurrences;
    }

    /**
     * @notice Get an occurrence by ID
     *
     * @param _occurrenceIdId The ID of the occurrence
     * @return occurrence The occurrence
     */
    function getOccurrenceById(bytes32 _occurrenceIdId) external view returns (Structs.Occurrence memory) {
        return occurrences[_occurrenceIdId];
    }

    /**
     * External/Public functions
     */

    /**
     * @notice Create an occurrence
     * @param _data The occurrence encoded bytes
     *
     * @return occurrenceId The ID of the occurrence
     */
    function createOccurrence(bytes memory _data) external returns (bytes32) {
        Structs.Occurrence memory decodedOccurrence = abi.decode(_data, (Structs.Occurrence));

        _checkDates(decodedOccurrence.start, decodedOccurrence.end);

        return _createOccurrence(_data, msg.sender);
    }

    /**
     * @notice Update an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     * @param _data The encoded bytes of the occurrence
     */
    function updateOccurrence(
        bytes32 _occurrenceId,
        bytes memory _data
    )
        external
        onlyCreator(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        Structs.Occurrence memory decodedOccurrence = abi.decode(_data, (Structs.Occurrence));

        _checkDates(decodedOccurrence.start, decodedOccurrence.end);

        return _updateOccurrence(_occurrenceId, _data, msg.sender);
    }

    /**
     * @notice Host an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     * @param _attendees The attendees of the occurrence
     */
    function hostOccurrence(
        bytes32 _occurrenceId,
        address[] memory _attendees
    )
        external
        onlyCreator(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        if (_attendees.length == 0) {
            revert Errors.NoAttendees();
        }

        for (uint256 i = 0; i < _attendees.length; i++) {
            if (_attendees[i] == address(0)) {
                revert Errors.ZeroAddress();
            }
        }

        attendeesAtEvent[_occurrenceId] = _attendees;
        occurrences[_occurrenceId].status = Enums.Status.Hosted;
        occurrences[_occurrenceId].attendees = _attendees;
    }

    /**
     * @notice Recognize an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     */
    function recognizeOccurrence(
        bytes32 _occurrenceId,
        Structs.Metadata memory _content
    )
        external
        onlyStaffAndAdmin(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        occurrences[_occurrenceId].metadata = _content;
        occurrences[_occurrenceId].status = Enums.Status.Recognized;
        occurrences[_occurrenceId].metadata = _content;
    }

    /**
     * @notice Cancel an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     */
    function cancelOccurrence(bytes32 _occurrenceId)
        external
        onlyCreator(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        occurrences[_occurrenceId].status = Enums.Status.Canceled;
    }

    function updateOccurrenceDates(
        bytes32 _occurrenceId,
        uint256 _start,
        uint256 _end
    )
        external
        onlyCreator(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        _checkDates(_start, _end);
        occurrences[_occurrenceId].start = _start;
        occurrences[_occurrenceId].end = _end;
    }

    /**
     * @notice Reject an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     */
    function rejectOccurrence(bytes32 _occurrenceId)
        external
        onlyCreator(_occurrenceId, msg.sender)
        occurrenceExists(_occurrenceId)
    {
        occurrences[_occurrenceId].status = Enums.Status.Rejected;
    }

    /**
     * Internal Functions
     */
    function _checkDates(uint256 _start, uint256 _end) internal pure {
        if (_start > _end) {
            revert Errors.InvalidDates(_start, _end);
        }
    }

    /**
     * @notice Create an occurrence
     *
     * @param _data the encoded bytes of the occurrence
     *
     * @return occurrenceId The ID of the occurrence
     */
    function _createOccurrence(bytes memory _data, address _sender) internal returns (bytes32) {
        Structs.Occurrence memory decodedOccurrence = abi.decode(_data, (Structs.Occurrence));
        bytes32 newId = keccak256(abi.encode(decodedOccurrence.name, _sender));

        Structs.Occurrence memory newOccurrence = occurrences[newId];
        newOccurrence.id = newId;
        newOccurrence.creator = _sender;
        newOccurrence.name = decodedOccurrence.name;
        newOccurrence.description = decodedOccurrence.description;
        newOccurrence.start = decodedOccurrence.start;
        newOccurrence.end = decodedOccurrence.end;
        newOccurrence.price = decodedOccurrence.price;
        newOccurrence.token = decodedOccurrence.token;
        newOccurrence.status = Enums.Status.Pending;
        newOccurrence.staff = decodedOccurrence.staff;
        newOccurrence.metadata = decodedOccurrence.metadata;
        newOccurrence.attendees = decodedOccurrence.attendees;

        occurrences[newOccurrence.id] = newOccurrence;
        _occurrenceCount++;

        uint256 staffLength = decodedOccurrence.staff.length;
        for (uint256 i = 0; i < staffLength; i++) {
            Structs.Staff memory _staffMember = staff[newOccurrence.id][decodedOccurrence.staff[i]];
            _staffMember = staff[newOccurrence.id][decodedOccurrence.staff[i]];
            _staffMember.id = keccak256(abi.encode(newId, decodedOccurrence.staff[i]));
            _staffMember.member = decodedOccurrence.staff[i];
            _staffMember.metadata = decodedOccurrence.metadata;
            _staffMember.status = Enums.Status.Active;

            staff[newOccurrence.id][decodedOccurrence.staff[i]] = _staffMember;
            // addStaffMember(newOccurrence.id, _staffMember.member, _metadata);
        }

        emit Events.OccurrenceCreated(newId, _sender);

        return newOccurrence.id;
    }

    /**
     * @notice Update an occurrence
     *
     * @param _occurrenceId The id of the occurrence
     * @param _data The encoded Occurrence data
     */
    function _updateOccurrence(bytes32 _occurrenceId, bytes memory _data, address _sender) internal {
        Structs.Occurrence memory decodedOccurrence = abi.decode(_data, (Structs.Occurrence));
        Structs.Occurrence memory _occurrence = occurrences[_occurrenceId];

        _occurrence.name = decodedOccurrence.name;
        _occurrence.description = decodedOccurrence.description;
        _occurrence.start = decodedOccurrence.start;
        _occurrence.end = decodedOccurrence.end;
        _occurrence.price = decodedOccurrence.price;
        _occurrence.token = decodedOccurrence.token;
        _occurrence.staff = decodedOccurrence.staff;
        _occurrence.metadata = decodedOccurrence.metadata;
        _occurrence.attendees = decodedOccurrence.attendees;

        occurrences[_occurrenceId] = _occurrence;

        emit Events.OccurrenceUpdated(_occurrenceId, _sender);
    }
}
