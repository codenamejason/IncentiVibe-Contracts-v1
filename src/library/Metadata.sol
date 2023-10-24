// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

/// @title Metadata
/// @author @codenamejason <jax@jaxcoder.xyz>
/// @notice Metadata is used to define the metadata that is used throughout the system.
struct Metadata {
    /// @notice Protocol ID corresponding to a specific protocol (currently using IPFS = 1)
    uint256 protocol;
    /// @notice Pointer (hash) to fetch metadata for the specified protocol
    string pointer;
}
