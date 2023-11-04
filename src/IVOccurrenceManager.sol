// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

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

    modifier onlyCreator(bytes32 _occurenceId) {
        if (occurrences[_occurenceId].creator != msg.sender) {
            revert Errors.NotCreator(msg.sender);
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
     * @return The id of the occurrence
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
    ) external returns (bytes32) {
        return _createOccurrence(
            _name, _description, _start, _end, _price, _token, _staff, _metadata, msg.sender
        );
    }

    function updateOccurrence(
        bytes32 _occurenceId,
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Structs.Metadata memory _metadata
    ) external onlyCreator(_occurenceId) occurrenceExists(_occurenceId) {
        return _updateOccurrence(
            _occurenceId,
            _name,
            _description,
            _start,
            _end,
            _price,
            _token,
            _staff,
            _metadata,
            msg.sender
        );
    }

    function getOccurrence(bytes32 _occurenceId)
        external
        view
        occurrenceExists(_occurenceId)
        returns (Structs.Occurrence memory)
    {
        return occurrences[_occurenceId];
    }

    function hostOccurrence(bytes32 _occurenceId, address[] memory _attendees)
        external
        onlyCreator(_occurenceId)
        occurrenceExists(_occurenceId)
    {
        attendeesAtEvent[_occurenceId] = _attendees;
        occurrences[_occurenceId].status = Enums.Status.Hosted;
    }

    function recognizeOccurrence(bytes32 _occurenceId, Structs.Metadata memory _content)
        external
        onlyStaff
        occurrenceExists(_occurenceId)
    {
        occurrences[_occurenceId].metadata = _content;
        occurrences[_occurenceId].status = Enums.Status.Recognized;
    }

    function getStaffMemberByOccurrenceId(bytes32 _occurenceId, address _member)
        external
        view
        occurrenceExists(_occurenceId)
        returns (Structs.Staff memory)
    {
        return staff[_member];
    }

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

    function getAttendeesByOccurrenceId(bytes32 _occurenceId)
        external
        view
        returns (address[] memory)
    {
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

    function getOccurrenceById(bytes32 _occurenceIdId)
        external
        view
        returns (Structs.Occurrence memory)
    {
        return occurrences[_occurenceIdId];
    }

    /**
     * Internal Functions
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
    ) internal returns (bytes32) {
        Structs.Occurrence memory _occurenceId = Structs.Occurrence({
            id: keccak256(abi.encodePacked(_name, _sender)),
            creator: msg.sender,
            name: _name,
            description: _description,
            start: _start,
            end: _end,
            price: _price,
            token: _token,
            status: Enums.Status.Pending,
            staff: _staff,
            metadata: _metadata
        });

        occurrences[_occurenceId.id] = _occurenceId;
        _occurrenceCount++;

        return _occurenceId.id;
    }

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
        address _sender
    ) internal {
        Structs.Occurrence memory _occurence = occurrences[_occurenceId];

        _occurence.name = _name;
        _occurence.description = _description;
        _occurence.start = _start;
        _occurence.end = _end;
        _occurence.price = _price;
        _occurence.token = _token;
        _occurence.staff = _staff;
        _occurence.metadata = _metadata;

        occurrences[_occurenceId] = _occurence;
    }
}
