// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { Occurrence } from "./library/Occurrence.sol";
import { Staff } from "./library/Staff.sol";
import { Enums } from "./library/Enums.sol";
import { Metadata } from "./library/Metadata.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title IVOccurrenceManager
 * @notice The IVOccurrenceManager contract is responsible for managing the occurrences
 * @dev We use the term occurrence to describe an event, appointment, or any other type of gathering.
 * @author @codenamejason <jax@jaxdoder.xyz>
 */
contract IVOccurrenceManager is AccessControl {
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");

    mapping(address => Staff) public staff;
    mapping(bytes32 => Occurrence) public occurrences;

    modifier onlyCreator() {
        require(hasRole(CREATOR_ROLE, msg.sender), "IVOccurrenceManager: caller is not a creator");
        _;
    }

    modifier onlyStaff() {
        require(hasRole(STAFF_ROLE, msg.sender), "IVOccurrenceManager: caller is not a staff");
        _;
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "IVOccurrenceManager: caller is not an admin"
        );
        _;
    }

    constructor(address _defaultAdmin) {
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
        Metadata memory _metadata
    ) external returns (bytes32) {
        Occurrence memory _occurenceId = Occurrence({
            id: keccak256(abi.encodePacked(_name, _start, _end)),
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

        return _occurenceId.id;
    }

    function updateOccurrence(
        bytes32 _occurenceIdId,
        string memory _name,
        string memory _description,
        uint256 _start,
        uint256 _end,
        uint256 _price,
        address _token,
        address[] memory _staff,
        Metadata memory _metadata
    ) external onlyCreator {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        Occurrence memory _occurenceId = Occurrence({
            id: keccak256(abi.encodePacked(_name, _start, _end)),
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
    }

    function addStaffMember(
        address _member,
        // uint256[] memory _levels,
        Metadata memory _metadata
    ) external onlyCreator {
        Staff memory _staff = Staff({
            id: keccak256(abi.encodePacked(_member)),
            member: _member,
            metadata: _metadata,
            // levels: _levels,
            status: Enums.Status.Pending
        });

        _grantRole(STAFF_ROLE, _member);

        // for (uint256 i = 0; i < _levels.length; i++) {
        //     _staff.levels[_member].push(_levels[i]);
        // }

        staff[_staff.member] = _staff;
    }

    function updateStaffMember(
        address _member,
        // uint256[] memory _levels,
        Metadata memory _metadata
    ) external onlyCreator {
        Staff memory _staff = Staff({
            id: keccak256(abi.encodePacked(_member)),
            member: _member,
            metadata: _metadata,
            // levels: _levels,
            status: Enums.Status.Pending
        });

        // for (uint256 i = 0; i < _levels.length; i++) {
        //     _staff.levels[_member].push(_levels[i]);
        // }

        staff[_staff.member] = _staff;
    }

    function updateStaffMemberStatus(address _member, Enums.Status _status) external onlyCreator {
        Staff memory _staff = staff[_member];
        _staff.status = _status;

        staff[_staff.member] = _staff;
    }

    function updateOccurrenceStatus(bytes32 _occurenceIdId, Enums.Status _status)
        external
        onlyCreator
    {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        Occurrence memory _occurenceId = occurrences[_occurenceIdId];
        _occurenceId.status = _status;

        occurrences[_occurenceId.id] = _occurenceId;
    }

    function getOccurrence(bytes32 _occurenceIdId) external view returns (Occurrence memory) {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        return occurrences[_occurenceIdId];
    }

    function getStaffMember(bytes32 _occurenceIdId, address _member)
        external
        view
        returns (Staff memory)
    {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        return staff[_member];
    }

    function getStaffMembers(bytes32 _occurenceIdId) external view returns (Staff[] memory) {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        Occurrence memory _occurenceId = occurrences[_occurenceIdId];
        Staff[] memory _staff = new Staff[](_occurenceId.staff.length);

        for (uint256 i = 0; i < _occurenceId.staff.length; i++) {
            _staff[i] = staff[_occurenceId.staff[i]];
        }

        return _staff;
    }

    function getOccurrences() external view returns (Occurrence[] memory) {
        // TODO:
    }

    function getOccurrenceById(bytes32 _occurenceIdId) external view returns (Occurrence memory) {
        return occurrences[_occurenceIdId];
    }
}
