// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { IVStaffManager } from "./IVStaffManager.sol";
import { IIVCommunityManager } from "./interfaces/IIVCommunityManager.sol";
import { Enums } from "./library/Enums.sol";
import { Structs } from "./library/Structs.sol";
import { Errors } from "./library/Errors.sol";

contract IVCommunityManager is IIVCommunityManager, IVStaffManager {
    /**
     * Storage
     */
    mapping(bytes32 => Structs.Community) public community;

    constructor(address _defaultAdmin) IVStaffManager(_defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /**
     * View functions
     */
    function getCommunityById(bytes32 _communityId) external view returns (Structs.Community memory) {
        Structs.Community memory _community = community[_communityId];

        return _community;
    }

    /**
     * External functions
     */
    function createCommunity(bytes memory _data) external returns (bytes32) {
        Structs.Community memory _community = abi.decode(_data, (Structs.Community));
        bytes32 _communityId = keccak256(abi.encodePacked(_community.name, _community.creator));
        community[_communityId] = _community;

        return _communityId;
    }

    function updateCommunity(bytes32 _communityId, bytes memory _data) external { }

    /**
     * Internal functions
     */
}
