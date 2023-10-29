// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { Errors } from "./library/Errors.sol";
import { Structs } from "./library/Structs.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RedemtionModule {
    // occurrenceId => token => bool
    mapping(bytes32 => mapping(uint256 => bool)) public redeemed;

    constructor() { }

    /**
     * @notice Returns if the token has been redeemed for an event
     * @param _occurrenceId The event ID
     * @param _tokenId The token ID
     * @return bool Returns true if the token has been redeemed
     */
    function isRedeemed(bytes32 _occurrenceId, uint256 _tokenId) external view returns (bool) {
        return redeemed[_occurrenceId][_tokenId];
    }

    function redeem(bytes32 _occurrenceId, uint256 _tokenId, address _recipient) external {
        if (_recipient == address(0)) revert Errors.ZeroAddress();
        if (redeemed[_occurrenceId][_tokenId]) {
            revert Errors.AlreadyRedeemed(_occurrenceId, _tokenId);
        }

        redeemed[_occurrenceId][_tokenId] = true;
    }
}
