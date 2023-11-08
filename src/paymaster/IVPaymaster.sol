// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract IVPaymaster is AccessControl {
    constructor(address _defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }
}
