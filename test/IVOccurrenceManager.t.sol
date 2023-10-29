// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test, console2, StdUtils } from "forge-std/Test.sol";

import { IVOccurrenceManager } from "../src/IVOccurrenceManager.sol";
import { Occurrence } from "../src/library/Occurrence.sol";
import { Enums } from "../src/library/Enums.sol";
import { Metadata } from "../src/library/Metadata.sol";

contract IVOccurrenceManagerTest is Test {
    IVOccurrenceManager ivOccurrenceManager;

    function setUp() public {
        address admin = makeAddr("admin");
        ivOccurrenceManager = new IVOccurrenceManager(admin);
        // ivOccurrenceManager.addStaffMember(_member, _metadata);
    }

    function test_CreateOccurrence() public {
        address creator = makeAddr("creator");
        address[] memory staff = new address[](1);
        staff[0] = makeAddr("staff");
        vm.prank(creator);
        bytes32 occurrence = ivOccurrenceManager.createOccurrence(
            "name",
            "description",
            1,
            2,
            3,
            // todo: add mock
            address(makeAddr("token")),
            staff,
            Metadata({ protocol: 1, pointer: "0x230847695gbv2-3" })
        );

        (bytes32 _occurrence,, string memory name, string memory description, uint256 start,,,,,) =
            ivOccurrenceManager.occurrences(occurrence);

        assertEq(_occurrence, occurrence);
        assertEq(name, "name");
        assertEq(description, "description");
        assertEq(start, 1);
    }
}
