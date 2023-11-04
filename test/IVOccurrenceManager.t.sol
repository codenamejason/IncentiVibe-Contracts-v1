// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { IVOccurrenceManager } from "../src/IVOccurrenceManager.sol";
import { Enums } from "../src/library/Enums.sol";
import { Structs } from "../src/library/Structs.sol";

contract IVOccurrenceManagerTest is Test {
    IVOccurrenceManager ivOccurrenceManager;

    address creator = makeAddr("creator");

    function setUp() public {
        address admin = makeAddr("admin");
        ivOccurrenceManager = new IVOccurrenceManager(admin);
        // ivOccurrenceManager.addStaffMember(_member, _metadata);
    }

    function _createOccurrence() internal returns (bytes32) {
        vm.prank(creator);
        address[] memory staff = new address[](1);
        staff[0] = makeAddr("staff");
        bytes32 occurrenceId = ivOccurrenceManager.createOccurrence(
            "name",
            "description",
            1,
            2,
            3,
            // todo: add mock
            address(makeAddr("token")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );

        return occurrenceId;
    }

    function test_CreateOccurrence() public {
        bytes32 occurrence = _createOccurrence();

        (bytes32 occurrenceId,, string memory name, string memory description, uint256 start,,,,,) =
            ivOccurrenceManager.occurrences(occurrence);

        assertEq(occurrenceId, occurrence);
        assertEq(name, "name");
        assertEq(description, "description");
        assertEq(start, 1);
    }

    function test_updateOccurrence() public {
        vm.startPrank(makeAddr("creator"));
    }

    function test_getOccurrence() public {
        bytes32 occurrence = _createOccurrence();

        Structs.Occurrence memory occurrenceStruct = ivOccurrenceManager.getOccurrence(occurrence);

        assertEq(occurrenceStruct.id, occurrence);
        assertEq(occurrenceStruct.name, "name");
        assertEq(occurrenceStruct.description, "description");
        assertEq(occurrenceStruct.start, 1);
    }

    function test_hostOccurrence() public {
        bytes32 occurrence = _createOccurrence();

        address[] memory _attendees = new address[](1);
        _attendees[0] = makeAddr("attendee");

        vm.startPrank(makeAddr("creator"));
        ivOccurrenceManager.hostOccurrence(occurrence, _attendees);

        address[] memory attendees;

        attendees = ivOccurrenceManager.getAttendeesByOccurrenceId(occurrence);

        assertEq(attendees[0], _attendees[0]);
        // assertEq(attendee[0].status, Enums.Status.Hosted);
    }

    function test_revert_hostOccurrence_NotCreator() public {
        bytes32 occurrence = _createOccurrence();
        address[] memory attendees = new address[](1);
        attendees[0] = makeAddr("attendee");

        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(occurrence, attendees);
    }

    function test_revert_hostOccurrence_OccurrenceDoesNotExist() public {
        bytes32 occurrence = keccak256(abi.encode(makeAddr("chad")));
        address[] memory attendees = new address[](1);
        attendees[0] = makeAddr("attendee");

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(occurrence, attendees);
    }
}
