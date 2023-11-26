// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { IVOccurrenceManager } from "../src/IVOccurrenceManager.sol";
import { Enums } from "../src/library/Enums.sol";
import { Structs } from "../src/library/Structs.sol";
import { Errors } from "../src/library/Errors.sol";

contract IVOccurrenceManagerTest is Test {
    IVOccurrenceManager ivOccurrenceManager;

    address creator = makeAddr("creator");
    address[] public staff;
    address[] public attendees;

    function setUp() public {
        address admin = makeAddr("admin");
        ivOccurrenceManager = new IVOccurrenceManager(admin);
        // ivOccurrenceManager.addStaffMember(_member, _metadata);

        staff = new address[](1);
        staff[0] = makeAddr("staff");

        attendees = new address[](1);
        attendees[0] = makeAddr("attendee");
        attendees[1] = makeAddr("attendee2");
    }

    function _createOccurrence() internal returns (bytes32) {
        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.createOccurrence(
            "name",
            "description",
            2,
            1,
            3,
            address(makeAddr("token")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );
    }

    function test_updateOccurrence() public {
        bytes32 _occurrenceId = __create_occurrence();

        vm.prank(creator);
        ivOccurrenceManager.updateOccurrence(
            _occurrenceId,
            "name2",
            "description2",
            2,
            3,
            4,
            address(makeAddr("token2")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );

        (bytes32 _occurrence2Id,, string memory name, string memory description, uint256 start,,,,,) =
            ivOccurrenceManager.occurrences(_occurrenceId);

        assertEq(_occurrenceId, _occurrence2Id);
        assertEq(name, "name2");
        assertEq(description, "description2");
        assertEq(start, 2);
    }

    function testRevert_updateOccurrence_NotCreator() public {
        bytes32 _occurrence = __create_occurrence();
        vm.prank(makeAddr("not-creator"));
        vm.expectRevert();
        ivOccurrenceManager.updateOccurrence(
            _occurrence,
            "name2",
            "description2",
            2,
            3,
            4,
            address(makeAddr("token2")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );
    }

    function testRevert_updateOccurrence_OccurrenceDoesNotExist() public {
        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.updateOccurrence(
            bytes32("0x1234"),
            "name2",
            "description2",
            2,
            3,
            4,
            address(makeAddr("token2")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );
    }

    function testRevert_updateOccurrence_InvalidDates() public {
        bytes32 _occurrence = __create_occurrence();
        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.updateOccurrence(
            _occurrence,
            "name2",
            "description2",
            3,
            2,
            4,
            address(makeAddr("token2")),
            staff,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );
    }

    function test_hostOccurrence() public {
        bytes32 _occurrence = __create_occurrence();

        attendees[0] = makeAddr("attendee");

        vm.prank(creator);
        ivOccurrenceManager.hostOccurrence(_occurrence, attendees);
    }

    function testRevert_hostOccurrence_NotCreator() public {
        bytes32 _occurrence = __create_occurrence();
        attendees[0] = makeAddr("attendee");

        vm.prank(makeAddr("not-creator"));
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(_occurrence, attendees);
    }

    function testRevert_hostOccurrence_OccurrenceDoesNotExist() public {

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(bytes32("0x1234"), attendees);
    }

    function testRevert_hostOccurrence_InvalidAttendees() public {
        bytes32 _occurrence = __create_occurrence();

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(_occurrence, attendees);

        address[] memory attendees2 = new address[](1);
        attendees[0] = address(0);

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(_occurrence, attendees2);
    }

    function test_recognizeOccurrence() public {
        bytes32 _occurrence = __create_occurrence();

        vm.prank(staff[0]);
        ivOccurrenceManager.recognizeOccurrence(
            _occurrence,
            Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );
    }

    function __create_occurrence() internal returns (bytes32) {
        vm.prank(creator);
        bytes32 occurrenceId = ivOccurrenceManager.createOccurrence(
            "name",
            "description",
            1,
            2,
            3,
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

        attendees = ivOccurrenceManager.getAttendeesByOccurrenceId(occurrence);

        assertEq(attendees[0], _attendees[0]);
        // assertEq(attendee[0].status, Enums.Status.Hosted);
    }

    function test_revert_hostOccurrence_NotCreator() public {
        bytes32 occurrence = _createOccurrence();
        attendees[0] = makeAddr("attendee");

        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(occurrence, attendees);
    }

    function test_revert_hostOccurrence_OccurrenceDoesNotExist() public {
        bytes32 occurrence = keccak256(abi.encode(makeAddr("chad")));
        attendees[0] = makeAddr("attendee");

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(occurrence, attendees);
    }
}
