// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title IVERC20BaseToken
/// @notice This is the base token contract used for the IVToken contracts.
/// @dev This contract is used to deploy the projects ERC20 token contracts.
/// @author @codenamejason <jax@jaxcoder.xyz>
contract IVERC20BaseToken is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Votes
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyAdminAndPauser() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(PAUSER_ROLE, msg.sender),
            "Caller is not an admin or pauser"
        );
        _;
    }

    modifier onlyAdminAndMinter() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(MINTER_ROLE, msg.sender),
            "Caller is not an admin or minter"
        );
        _;
    }

    constructor(
        address defaultAdmin,
        address minter,
        address pauser,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(PAUSER_ROLE, pauser);
    }

    function pause() public onlyAdminAndPauser {
        _pause();
    }

    function unpause() public onlyAdminAndPauser {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyAdminAndMinter {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function transfer(address, uint256) public pure override(ERC20) returns (bool) {
        revert("Transfer is disabled");
    }

    function transferFrom(address, address, uint256) public pure override(ERC20) returns (bool) {
        revert("Transfer is disabled");
    }
}
