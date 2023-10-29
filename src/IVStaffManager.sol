// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { Enums } from "./library/Enums.sol";
import { Structs } from "../src/library/Structs.sol";
import { Errors } from "../src/library/Errors.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract IVStaffManager is AccessControl {
    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");

    mapping(address => Structs.Staff) public staff;

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "IVOccurrenceManager: caller is not an admin"
        );
        _;
    }

    modifier onlyStaff() {
        require(hasRole(STAFF_ROLE, msg.sender), "IVOccurrenceManager: caller is not a staff");
        _;
    }

    constructor(address _defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    function addStaffMember(
        address _member,
        // uint256[] memory _levels,
        Structs.Metadata memory _metadata
    ) external onlyAdmin {
        Structs.Staff memory _staff = Structs.Staff({
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
        Structs.Metadata memory _metadata
    ) external onlyAdmin {
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

        staff[_staff.member] = _staff;
    }

    function updateStaffMemberStatus(address _member, Enums.Status _status) external onlyAdmin {
        Structs.Staff memory _staff = staff[_member];
        _staff.status = _status;

        staff[_staff.member] = _staff;
    }
}
