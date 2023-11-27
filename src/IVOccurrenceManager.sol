// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { IVStaffManager } from "./IVStaffManager.sol";
import { IIVOccurrenceManager } from "./interfaces/IIVOccurrenceManager.sol";
import { Enums } from "./library/Enums.sol";
import { Structs } from "./library/Structs.sol";
import { Errors } from "./library/Errors.sol";

// import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title IVOccurrenceManager
 * @notice The IVOccurrenceManager contract is responsible for managing the occurrences
 * @dev We use the term occurrence to describe an event, appointment, or any other type of gathering.
 * @author @codenamejason <jax@jaxdoder.xyz>
 */
contract IVOccurrenceManager is IIVOccurrenceManager, IVStaffManager {
    mapping(bytes32 => Structs.Occurrence) public occurrences;
    mapping(bytes32 => address[]) public attendeesAtEvent;
    mapping(bytes32 => mapping(bytes32 => Structs.Attendee)) public attendeeAtEvent;
    uint256 private _occurrenceCount;

    modifier onlyCreator(bytes32 _occurenceId, address _creator) {
        if (occurrences[_occurenceId].creator != _creator) {
            revert Errors.NotCreator(_creator);
        }
        _;
    }

    modifier occurrenceExists(bytes32 _occurenceIdId) {
        if (occurrences[_occurenceIdId].id != _occurenceIdId) {
            revert Errors.OccurrenceDoesNotExist(_occurenceIdId);
        }
        _;
    }

    constructor(address _defaultAdmin) IVStaffManager(_defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /**
     * @notice Create an occurrence
     * @param _name The name of the occurrence
     * @param _description The description of the occurrence
     * @param _start The start time of the occurrence
     * @param _end The end time of the occurrence
     * @param _price The price of the occurrence
     * @param _token The token address of the occurrence
     * @param _staff The staff addresses of the occurrence
     * @param _metadata The metadata of the occurrence
     * @return occurrenceId The ID of the occurrence
     */
    function createOccurrence(
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Structs.Metadata memory _metadata
    )
        external
        returns (bytes32)
    {
        _checkDates(_start, _end);

        return _createOccurrence(_name, _description, _start, _end, _price, _token, _staff, _metadata, msg.sender);
    }

    /**
     * @notice Update an occurrence
     *
     * @param _occurenceId The id of the occurrence
     * @param _name The name of the occurrence
     * @param _description The description of the occurrence
     * @param _start The start time of the occurrence
     * @param _end The end time of the occurrence
     * @param _price The price of the occurrence
     * @param _token The token address of the occurrence
     * @param _staff The staff addresses of the occurrence
     * @param _metadata The metadata of the occurrence
     */
    function updateOccurrence(
        bytes32 _occurenceId,
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Structs.Metadata memory _metadata,
        address[] memory _attendees
    )
        external
        onlyCreator(_occurenceId, msg.sender)
        occurrenceExists(_occurenceId)
    {
        _checkDates(_start, _end);

        return _updateOccurrence(
            _occurenceId, _name, _description, _start, _end, _price, _token, _staff, _metadata, _attendees
        );
    }

    /**
     * @notice Get an occurrence
     *
     * @param _occurenceId The id of the occurrence
     * @return occurrence The occurrence
     */
    function getOccurrence(bytes32 _occurenceId)
        external
        view
        occurrenceExists(_occurenceId)
        returns (Structs.Occurrence memory)
    {
        return occurrences[_occurenceId];
    }

    /**
     * @notice Host an occurrence
     *
     * @param _occurenceId The id of the occurrence
     * @param _attendees The attendees of the occurrence
     */
    function hostOccurrence(
        bytes32 _occurenceId,
        address[] memory _attendees
    )
        external
        onlyCreator(_occurenceId, msg.sender)
        occurrenceExists(_occurenceId)
    {
        if (_attendees.length == 0) {
            revert Errors.NoAttendees();
        }

        for (uint256 i = 0; i < _attendees.length; i++) {
            if (_attendees[i] == address(0)) {
                revert Errors.ZeroAddress();
            }
        }

        attendeesAtEvent[_occurenceId] = _attendees;
        occurrences[_occurenceId].status = Enums.Status.Hosted;
        occurrences[_occurenceId].attendees = _attendees;
    }

    /**
     * @notice Recognize an occurrence
     *
     * @param _occurenceId The id of the occurrence
     */
    function recognizeOccurrence(
        bytes32 _occurenceId,
        Structs.Metadata memory _content
    )
        external
        onlyStaff(msg.sender)
        occurrenceExists(_occurenceId)
    {
        occurrences[_occurenceId].metadata = _content;
        occurrences[_occurenceId].status = Enums.Status.Recognized;
        occurrences[_occurenceId].metadata = _content;
    }

    /**
     * @notice Cancel an occurrence
     *
     * @param _occurenceId The id of the occurrence
     */
    function cancelOccurrence(bytes32 _occurenceId)
        external
        onlyCreator(_occurenceId, msg.sender)
        occurrenceExists(_occurenceId)
    {
        occurrences[_occurenceId].status = Enums.Status.Canceled;
    }

    function updateOccurrenceDates(
        bytes32 _occurenceId,
        uint256 _start,
        uint256 _end
    )
        external
        onlyCreator(_occurenceId, msg.sender)
        occurrenceExists(_occurenceId)
    {
        _checkDates(_start, _end);
        occurrences[_occurenceId].start = _start;
        occurrences[_occurenceId].end = _end;
    }

    /**
     * @notice Reject an occurrence
     *
     * @param _occurenceId The id of the occurrence
     */
    function rejectOccurrence(bytes32 _occurenceId)
        external
        onlyCreator(_occurenceId, msg.sender)
        occurrenceExists(_occurenceId)
    {
        occurrences[_occurenceId].status = Enums.Status.Rejected;
    }

    /**
     * @notice Get a staff member
     *
     * @param _occurenceId The ID of the occurrence
     * @param _member The address of the staff member
     * @return staffMember The staff member
     */
    function getStaffMemberByOccurrenceId(
        bytes32 _occurenceId,
        address _member
    )
        external
        view
        occurrenceExists(_occurenceId)
        returns (Structs.Staff memory)
    {
        return staff[_member];
    }

    /**
     * @notice Get staff members for an occurrence
     *
     * @param _occurenceId The ID of the occurrence
     * @return staffMembers The staff members
     */
    function getStaffMembersForOccurrenceId(bytes32 _occurenceId)
        external
        view
        occurrenceExists(_occurenceId)
        returns (Structs.Staff[] memory)
    {
        Structs.Occurrence memory occurrence = occurrences[_occurenceId];
        Structs.Staff[] memory _staff = new Structs.Staff[](occurrence.staff.length);

        for (uint256 i = 0; i < occurrence.staff.length; i++) {
            _staff[i] = staff[occurrence.staff[i]];
        }

        return _staff;
    }

    function getAttendeesByOccurrenceId(bytes32 _occurenceId) external view returns (address[] memory) {
        return attendeesAtEvent[_occurenceId];
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
     * @param _occurenceIdId The ID of the occurrence
     * @return occurrence The occurrence
     */
    function getOccurrenceById(bytes32 _occurenceIdId) external view returns (Structs.Occurrence memory) {
        return occurrences[_occurenceIdId];
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
     * @param _name The name of the occurrence
     * @param _description The description of the occurrence
     * @param _start The start time of the occurrence
     * @param _end The end time of the occurrence
     * @param _price The price of the occurrence
     * @param _token The token address of the occurrence
     * @param _staff The staff addresses of the occurrence
     * @param _metadata The metadata of the occurrence
     * @return occurrenceId The ID of the occurrence
     */
    function _createOccurrence(
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Structs.Metadata memory _metadata,
        address _sender
    )
        internal
        returns (bytes32)
    {
        address[] memory _attendees = new address[](0);
        bytes32 newId = keccak256(abi.encode(_name, _sender));

        Structs.Occurrence memory newOccurrence = occurrences[newId];
        newOccurrence.creator = _sender;
        newOccurrence.name = _name;
        newOccurrence.description = _description;
        newOccurrence.start = _start;
        newOccurrence.end = _end;
        newOccurrence.price = _price;
        newOccurrence.token = _token;
        newOccurrence.status = Enums.Status.Pending;
        newOccurrence.staff = _staff;
        newOccurrence.metadata = _metadata;
        newOccurrence.attendees = _attendees;

        occurrences[newOccurrence.id] = newOccurrence;
        _occurrenceCount++;

        // Structs.Staff memory _staffMember = staff[_sender];
        // _staffMember.id = keccak256(abi.encode(newId, _sender));
        // _staffMember.member = _sender;
        // _staffMember.metadata = Structs.Metadata({ protocol: 1, pointer: "0x7128364591823674872ghsdfafjdhf" });
        // _staffMember.status = Enums.Status.Active;

        // staff[_sender] = _staffMember;

        return newOccurrence.id;
    }

    /**
     * @notice Update an occurrence
     *
     * @param _occurenceId The id of the occurrence
     * @param _name The name of the occurrence
     * @param _description The description of the occurrence
     * @param _start The start time of the occurrence
     * @param _end The end time of the occurrence
     * @param _price The price of the occurrence
     * @param _token The token address of the occurrence
     * @param _staff The staff addresses of the occurrence
     * @param _metadata The metadata of the occurrence
     */
    function _updateOccurrence(
        bytes32 _occurenceId,
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Structs.Metadata memory _metadata,
        address[] memory _attendees
    )
        internal
    {
        Structs.Occurrence memory _occurence = occurrences[_occurenceId];

        _occurence.name = _name;
        _occurence.description = _description;
        _occurence.start = _start;
        _occurence.end = _end;
        _occurence.price = _price;
        _occurence.token = _token;
        _occurence.staff = _staff;
        _occurence.metadata = _metadata;
        _occurence.attendees = _attendees;

        occurrences[_occurenceId] = _occurence;
    }
}
