// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

contract Enums {
    enum Status {
        Pending,
        Active,
        Recognized,
        Hosted,
        Inactive,
        Rejected,
        Canceled,
        Completed,
        Expired,
        Redeemed,
        Refunded,
        None
    }
}
