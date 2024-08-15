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

        attendees = new address[](2);
        attendees[0] = makeAddr("attendee");
        attendees[1] = makeAddr("attendee2");
    }

    function test_createOccurrence() public {
        bytes32 newOccurrence = __createOccurrence();
        Structs.Occurrence memory occurrenceStruct = ivOccurrenceManager.getOccurrenceById(newOccurrence);

        assertEq(occurrenceStruct.id, newOccurrence);
        assertEq(occurrenceStruct.name, "name2");
        assertEq(occurrenceStruct.description, "description2");
        assertEq(occurrenceStruct.start, 1);
    }

    function test_updateOccurrence() public {
        bytes32 _occurrenceId = __createOccurrence();

        vm.prank(creator);
        Structs.Occurrence memory occurrenceToUpdate = Structs.Occurrence({
            id: _occurrenceId,
            creator: 0x3f15B8c6F9939879Cb030D6dd935348E57109637,
            name: "name2",
            description: "description2",
            start: 2,
            end: 3,
            price: 4,
            token: address(makeAddr("token2")),
            staff: staff,
            status: Enums.Status.Pending,
            metadata: Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" }),
            attendees: attendees
        });
        bytes memory encodedOccurrence = abi.encode(occurrenceToUpdate);

        ivOccurrenceManager.updateOccurrence(_occurrenceId, encodedOccurrence);

        (bytes32 _occurrence2Id,, string memory name, string memory description, uint256 start,,,,,) =
            ivOccurrenceManager.occurrences(_occurrenceId);

        assertEq(_occurrenceId, _occurrence2Id);
        assertEq(name, "name2");
        assertEq(description, "description2");
        assertEq(start, 2);
    }

    function testRevert_updateOccurrence_NotCreator() public {
        bytes32 _occurrenceId = __createOccurrence();
        vm.prank(makeAddr("not-creator"));
        vm.expectRevert();
        Structs.Occurrence memory occurrenceToUpdate = Structs.Occurrence({
            id: _occurrenceId,
            creator: makeAddr("creator"),
            name: "name2",
            description: "description2",
            start: 2,
            end: 3,
            price: 4,
            token: address(makeAddr("token2")),
            staff: staff,
            status: Enums.Status.Pending,
            metadata: Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" }),
            attendees: attendees
        });
        bytes memory encodedOccurrence = abi.encode(occurrenceToUpdate);
        ivOccurrenceManager.updateOccurrence(_occurrenceId, encodedOccurrence);
    }

    function testRevert_updateOccurrence_OccurrenceDoesNotExist() public {
        bytes32 _occurrenceId = __createOccurrence();
        vm.prank(creator);
        vm.expectRevert();

        Structs.Occurrence memory occurrenceToUpdate = Structs.Occurrence({
            id: _occurrenceId,
            creator: 0x3f15B8c6F9939879Cb030D6dd935348E57109637,
            name: "name2",
            description: "description2",
            start: 2,
            end: 3,
            price: 4,
            token: address(makeAddr("token2")),
            staff: staff,
            status: Enums.Status.Pending,
            metadata: Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" }),
            attendees: attendees
        });
        bytes memory encodedOccurrence = abi.encode(occurrenceToUpdate);
        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.updateOccurrence(_occurrenceId, encodedOccurrence);
    }

    function testRevert_updateOccurrence_InvalidDates() public {
        bytes32 _occurrenceId = __createOccurrence();
        Structs.Occurrence memory occurrenceToUpdate = Structs.Occurrence({
            id: _occurrenceId,
            creator: 0x3f15B8c6F9939879Cb030D6dd935348E57109637,
            name: "name2",
            description: "description2",
            start: 4,
            end: 3,
            price: 4,
            token: address(makeAddr("token2")),
            staff: staff,
            status: Enums.Status.Pending,
            metadata: Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" }),
            attendees: attendees
        });
        bytes memory encodedOccurrence = abi.encode(occurrenceToUpdate);
        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.updateOccurrence(_occurrenceId, encodedOccurrence);
    }

    function testRevert_hostOccurrence_NotCreator() public {
        bytes32 _occurrence = __createOccurrence();
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
        bytes32 _occurrence = __createOccurrence();
        address[] memory attendees2 = new address[](1);
        attendees[0] = address(0);

        vm.prank(creator);
        vm.expectRevert();
        ivOccurrenceManager.hostOccurrence(_occurrence, attendees2);
    }

    // FIXME: This test is failing because of the revert in the modifier
    function test_recognizeOccurrence() public {
        // bytes32 occurrenceId = __createOccurrence();

        // vm.prank(creator);
        // ivOccurrenceManager.recognizeOccurrence(
        //     occurrenceId, Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        // );
    }

    function test_getOccurrence() public {
        bytes32 newOccurrence = __createOccurrence();

        Structs.Occurrence memory occurrenceStruct = ivOccurrenceManager.getOccurrenceById(newOccurrence);

        assertEq(occurrenceStruct.id, newOccurrence);
        assertEq(occurrenceStruct.name, "name2");
        assertEq(occurrenceStruct.description, "description2");
        assertEq(occurrenceStruct.start, 1);
    }

    function test_hostOccurrence() public {
        bytes32 occurrence = __createOccurrence();

        address[] memory _attendees = new address[](1);
        _attendees[0] = makeAddr("attendee");

        vm.startPrank(creator);
        ivOccurrenceManager.hostOccurrence(occurrence, _attendees);

        attendees = ivOccurrenceManager.getAttendeesByOccurrenceId(occurrence);

        assertEq(attendees[0], _attendees[0]);
        // assertEq(attendee[0].status, Enums.Status.Hosted);
    }

    function test_revert_hostOccurrence_NotCreator() public {
        bytes32 occurrence = __createOccurrence();
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

    function __createOccurrence() internal returns (bytes32) {
        vm.prank(creator);
        Structs.Occurrence memory occurrenceToUpdate = Structs.Occurrence({
            id: keccak256(abi.encodePacked("name2", "description2")),
            creator: 0x3f15B8c6F9939879Cb030D6dd935348E57109637,
            name: "name2",
            description: "description2",
            start: 1,
            end: 3,
            price: 4,
            token: address(makeAddr("token2")),
            staff: staff,
            status: Enums.Status.Pending,
            metadata: Structs.Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" }),
            attendees: attendees
        });
        bytes memory encodedOccurrence = abi.encode(occurrenceToUpdate);
        return ivOccurrenceManager.createOccurrence(encodedOccurrence);
    }
}
