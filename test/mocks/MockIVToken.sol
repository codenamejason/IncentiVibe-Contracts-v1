// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVERC20BaseToken } from "../../src/IVERC20BaseToken.sol";

contract MockIVToken is IVERC20BaseToken {
    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    ) IVERC20BaseToken(defaultAdmin, minter, pauser, name, symbol) { }
}
