// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

library Errors {
    error Unauthorized(address caller);
    error InvalidTokenId(uint256 tokenId);
    error MaxMintablePerClassReached(address recipient, uint256 classId, uint256 maxMintable);
    error AlreadyRedeemed(bytes32 occurrenceId, uint256 tokenId);
    error NewSupplyTooLow(uint256 minted, uint256 supply);
    error OccurrenceDoesNotExist(bytes32 occurrenceId);
    error NotCreator(address caller);
    error ZeroAddress();
    error ZeroAmount();
    error TransferFailed();
}
