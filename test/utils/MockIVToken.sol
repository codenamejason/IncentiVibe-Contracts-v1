// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVBaseToken } from "../../src/IVBaseToken.sol";

contract MockIVToken is IVBaseToken {
    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    ) IVBaseToken(defaultAdmin, minter, pauser, name, symbol) { }
}
