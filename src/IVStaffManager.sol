// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Enums } from "./library/Enums.sol";
import { Structs } from "../src/library/Structs.sol";
import { Errors } from "../src/library/Errors.sol";
import { Recover } from "../src/library/Recover.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract IVStaffManager is AccessControl, Recover {
    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(bytes32 => mapping(address => Structs.Staff)) public staff;

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "IVOccurrenceManager: caller is not an admin");
        _;
    }

    modifier onlyStaff(bytes32 _occurrenceId, address _staff) {
        if (staff[_occurrenceId][_staff].status != Enums.Status.Active) {
            revert Errors.OnlyStaff();
        }
        _;
    }

    modifier onlyStaffAndAdmin(bytes32 _occurrenceId, address _staff) {
        if (staff[_occurrenceId][_staff].status != Enums.Status.Active) {
            if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
                revert Errors.OnlyStaff();
            }
        }
        _;
    }

    constructor(address _defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    function addStaffMember(
        bytes32 _occurrenceId,
        address _member,
        // uint256[] memory _levels,
        Structs.Metadata memory _metadata
    )
        external
        virtual
        onlyAdmin
    {
        Structs.Staff memory _staff = Structs.Staff({
            id: keccak256(abi.encodePacked(_occurrenceId, _member)),
            member: _member,
            metadata: _metadata,
            // levels: _levels,
            status: Enums.Status.Pending
        });

        _grantRole(STAFF_ROLE, _member);

        // for (uint256 i = 0; i < _levels.length; i++) {
        //     _staff.levels[_member].push(_levels[i]);
        // }

        staff[_occurrenceId][_staff.member] = _staff;
    }

    function updateStaffMember(
        bytes32 _occurrenceId,
        address _member,
        // uint256[] memory _levels,
        Structs.Metadata memory _metadata
    )
        external
        virtual
        onlyAdmin
    {
        Structs.Staff memory _staff = Structs.Staff({
            id: keccak256(abi.encodePacked(_member)),
            member: _member,
            metadata: _metadata,
            // levels: _levels,
            status: Enums.Status.Pending
        });

        // for (uint256 i = 0; i < _levels.length; i++) {
        //     _staff.levels[_member].push(_levels[i]);
        // }

        staff[_occurrenceId][_staff.member] = _staff;
    }

    function removeStaffMember(bytes32 _occurrenceId, address _member) external virtual onlyAdmin {
        delete staff[_occurrenceId][_member];
    }

    function updateStaffMemberStatus(
        bytes32 _occurrenceId,
        address _member,
        Enums.Status _status
    )
        external
        virtual
        onlyAdmin
    {
        Structs.Staff memory _staff = staff[_occurrenceId][_member];
        _staff.status = _status;

        staff[_occurrenceId][_staff.member] = _staff;
    }

    function addStaffMemberMinterRole(address _member) external virtual onlyAdmin {
        _grantRole(MINTER_ROLE, _member);
    }

    /**
     * @notice Removes a campaign member
     * @dev This function is only callable by the owner
     * @param _member The member to remove
     */
    function removeCampaignMember(address _member) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, _member);
    }
}
