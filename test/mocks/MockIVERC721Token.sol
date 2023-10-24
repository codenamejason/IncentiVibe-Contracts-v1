// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVERC721BaseToken } from "../../src/IVERC721BaseToken.sol";

contract MockIVERC721Token is IVERC721BaseToken {
    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    ) IVERC721BaseToken(defaultAdmin, minter, pauser, name, symbol) { }
}
