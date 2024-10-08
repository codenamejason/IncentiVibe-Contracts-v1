// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { IVERC20BaseToken } from "../../src/IVERC20BaseToken.sol";

contract MockIVERC20Token is IVERC20BaseToken {
    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    )
        IVERC20BaseToken(defaultAdmin, minter, pauser, name, symbol)
    { }
}
