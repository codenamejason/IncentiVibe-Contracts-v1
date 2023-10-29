// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVStaffManager } from "./IVStaffManager.sol";
import { Enums } from "./library/Enums.sol";
import { Structs } from "./library/Structs.sol";

// import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title IVOccurrenceManager
 * @notice The IVOccurrenceManager contract is responsible for managing the occurrences
 * @dev We use the term occurrence to describe an event, appointment, or any other type of gathering.
 * @author @codenamejason <jax@jaxdoder.xyz>
 */
contract IVOccurrenceManager is IVStaffManager {
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    mapping(bytes32 => Structs.Occurrence) public occurrences;

    modifier onlyCreator() {
        require(hasRole(CREATOR_ROLE, msg.sender), "IVOccurrenceManager: caller is not a creator");
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
        Structs.Occurrence memory _occurenceId = Structs.Occurrence({
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
        Structs.Metadata memory _metadata
    ) external onlyCreator {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        Structs.Occurrence memory _occurenceId = Structs.Occurrence({
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

    function getOccurrence(bytes32 _occurenceIdId)
        external
        view
        returns (Structs.Occurrence memory)
    {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        return occurrences[_occurenceIdId];
    }

    function getStaffMember(bytes32 _occurenceIdId, address _member)
        external
        view
        returns (Structs.Staff memory)
    {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        return staff[_member];
    }

    function getStaffMembers(bytes32 _occurenceIdId)
        external
        view
        returns (Structs.Staff[] memory)
    {
        require(
            occurrences[_occurenceIdId].id == _occurenceIdId,
            "IVOccurrenceManager: occurrence does not exist"
        );

        Structs.Occurrence memory _occurenceId = occurrences[_occurenceIdId];
        Structs.Staff[] memory _staff = new Structs.Staff[](_occurenceId.staff.length);

        for (uint256 i = 0; i < _occurenceId.staff.length; i++) {
            _staff[i] = staff[_occurenceId.staff[i]];
        }

        return _staff;
    }

    function getOccurrences() external view returns (Structs.Occurrence[] memory) {
        // TODO:
    }

    function getOccurrenceById(bytes32 _occurenceIdId)
        external
        view
        returns (Structs.Occurrence memory)
    {
        return occurrences[_occurenceIdId];
    }
}
