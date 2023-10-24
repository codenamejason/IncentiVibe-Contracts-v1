// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Event } from "./library/Event.sol";
import { Staff } from "./library/Staff.sol";
import { StaffStatus } from "./library/Staff.sol";
import { Metadata } from "./library/Metadata.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract IVEventManager is AccessControl {
    enum EventStatus {
        Pending,
        Active,
        Cancelled,
        Completed
    }

    mapping(address => Staff) public staff;

    constructor(address _defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);

        Staff storage _staff = staff[_defaultAdmin];
        _staff.id = keccak256(abi.encodePacked("admin"));
        _staff.member = _defaultAdmin;
        _staff.metadata = Metadata({ protocol: 1, pointer: "https://mypointer.com" });
        _staff.status = StaffStatus.Active;
    }
}
