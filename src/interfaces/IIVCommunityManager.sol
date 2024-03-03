// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { Structs } from "../../src/library/Structs.sol";

interface IIVCommunityManager {
    function createCommunity(bytes calldata _data) external returns (bytes32);
    function updateCommunity(bytes32 _communityId, bytes memory _data) external;
    function getCommunityById(bytes32 _communityId) external view returns (Structs.Community memory);
}
