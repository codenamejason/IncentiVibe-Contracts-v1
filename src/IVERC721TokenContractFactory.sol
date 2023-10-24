// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { IVERC721BaseToken } from "./IVERC721BaseToken.sol";
import { Errors } from "./library/Errors.sol";

contract IVERC721TokenContractFactory {
    /// ======================
    /// ======= Events =======
    /// ======================

    /// @notice Emitted when a contract is deployed.
    event Deployed(address indexed deployed);

    /// ======================
    /// ======= Storage ======
    /// ======================

    struct Token {
        address defaultAdmin;
        address minter;
        address pauser;
        string name;
        string symbol;
        address contractAddress;
    }

    /// @notice Collection of authorized deployers.
    mapping(address => bool) public isDeployer;

    /// @notice Collection of deployed contracts.
    mapping(address => Token) public deployedTokens;

    /// ======================
    /// ======= Modifiers ====
    /// ======================

    /// @notice Modifier to ensure the caller is authorized to deploy and returns if not.
    modifier onlyDeployer() {
        _checkIsDeployer();
        _;
    }

    /// ======================
    /// ===== Constructor ====
    /// ======================

    /// @notice On deployment sets the 'msg.sender' to allowed deployer.
    constructor() {
        isDeployer[msg.sender] = true;
    }

    /// ===============================
    /// ====== Internal Functions =====
    /// ===============================

    /// @notice Checks if the caller is authorized to deploy.
    function _checkIsDeployer() internal view {
        if (!isDeployer[msg.sender]) revert Errors.Unauthorized(msg.sender);
    }

    /// ===============================
    /// ====== External Functions =====
    /// ===============================

    /// @notice Deploys a token contract.
    /// @dev Used for our deployments.
    /// @param _defaultAdmin Address of the default admin
    /// @param _minter Address of the minter
    /// @param _pauser Address of the pauser
    /// @param _name Name of the token
    /// @param _symbol Symbol of the token
    /// @return deployedContract Address of the deployed contract
    function create(
        address _defaultAdmin,
        address _minter,
        address _pauser,
        string memory _name,
        string memory _symbol
    ) external payable onlyDeployer returns (address deployedContract) {
        deployedContract = address(
            new IVERC721BaseToken(_defaultAdmin, _minter, _pauser, _name, _symbol)
        );

        // Set the token to the deployedTokens mapping
        deployedTokens[deployedContract] = Token({
            defaultAdmin: _defaultAdmin,
            minter: _minter,
            pauser: _pauser,
            name: _name,
            symbol: _symbol,
            contractAddress: deployedContract
        });

        emit Deployed(deployedContract);
    }

    /// @notice Set the allowed deployer.
    /// @dev 'msg.sender' must be a deployer.
    /// @param _deployer Address of the deployer to set
    /// @param _allowedToDeploy Boolean to set the deployer to
    function setDeployer(address _deployer, bool _allowedToDeploy) external onlyDeployer {
        // Set the deployer to the allowedToDeploy mapping
        isDeployer[_deployer] = _allowedToDeploy;
    }
}
