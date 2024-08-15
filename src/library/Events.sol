// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

library Events {
    event OccurrenceCreated(bytes32 id, address creator);
    event OccurrenceUpdated(bytes32 id, address updater);
}
