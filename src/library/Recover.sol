// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Recover {
    function recoverERC20(address _token) external {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }
}
