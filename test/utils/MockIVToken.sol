// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVBaseERC20Token } from "../../src/IVBaseERC20Token.sol";

contract MockIVToken is IVBaseERC20Token {
    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    ) IVBaseERC20Token(defaultAdmin, minter, pauser, name, symbol) { }
}
