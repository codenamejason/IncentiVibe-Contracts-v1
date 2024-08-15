// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.22;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Pausable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { ERC721Votes } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Votes.sol";

import { Errors } from "./library/Errors.sol";
import { Structs } from "./library/Structs.sol";
import { IVRedemtionModule } from "./IVRedemtionModule.sol";

contract IVERC721BaseToken is
    IVRedemtionModule,
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    AccessControl,
    ERC721Burnable,
    EIP712,
    ERC721Votes
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _tokenIds;
    uint256 public classIds;
    uint256 public totalClassesSupply;
    uint256 public maxMintablePerClass;

    mapping(uint256 => Structs.Class) public classes;
    mapping(address => mapping(uint256 => uint256)) public mintedPerClass;

    /**
     * Events ************
     */
    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(
        address indexed sender, uint256 indexed classId, uint256 indexed tokenId, string tokenURI
    );
    event ClassAdded(uint256 indexed classId, string metadata);
    event UpdatedClassTokenSupply(uint256 indexed classId, uint256 supply);
    event UpdatedMaxMintablePerClass(uint256 maxMintable);

    /**
     * Modifiers ************
     */

    /**
     * @notice Checks if the sender is a campaign member
     * @dev This modifier is used to check if the sender is a campaign member
     * @param sender The sender address
     */
    modifier onlyMinter(address sender) {
        if (!hasRole(MINTER_ROLE, sender)) {
            revert Errors.Unauthorized(sender);
        }
        _;
    }

    constructor(
        address _defaultAdmin,
        address _pauser,
        address _minter,
        string memory _name,
        string memory _symbol
    )
        ERC721(_name, _symbol)
        EIP712(_name, "1")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(PAUSER_ROLE, _pauser);
        _grantRole(MINTER_ROLE, _minter);
    }

    /**
     * External Functions *****
     */

    /**
     * @notice Awards nft to address
     * @dev This function is only callable by staff
     * @param _recipient The recipient of the item
     * @param _classId The class ID
     */
    function awardItem(address _recipient, uint256 _classId) external onlyMinter(msg.sender) returns (uint256) {
        if (mintedPerClass[_recipient][_classId] > maxMintablePerClass) {
            revert Errors.MaxMintablePerClassReached(_recipient, _classId, maxMintablePerClass);
        }

        uint256 tokenId = _mintItem(_recipient, _classId);
        mintedPerClass[_recipient][_classId]++;

        emit ItemAwarded(tokenId, _recipient, _classId);

        return tokenId;
    }

    /**
     * @notice Awards nft to a batch of addresses
     * @dev This function is only callable by staff
     * @param _recipients The recipients of the item
     * @param _classIds The class IDs
     */
    function batchAwardItem(
        address[] memory _recipients,
        uint256[] memory _classIds
    )
        external
        onlyMinter(msg.sender)
        returns (uint256[] memory)
    {
        uint256 length = _recipients.length;
        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length;) {
            if (mintedPerClass[_recipients[i]][_classIds[i]] > maxMintablePerClass) {
                revert("You have reached the max mintable for this class");
            }

            tokenIds[i] = _mintItem(_recipients[i], _classIds[i]);
            mintedPerClass[_recipients[i]][_classIds[i]]++;

            emit ItemAwarded(tokenIds[i], _recipients[i], _classIds[i]);

            unchecked {
                ++i;
            }
        }

        return tokenIds;
    }

    /**
     * @notice Adds a new class
     * @dev This function is only callable by staff
     * @param _name The name of the class
     * @param _description The description of the class
     * @param _imagePointer The image pointer for the class
     * @param _metadata The metadata pointer for the class
     * @param _supply The total supply of the class
     */
    function addClass(
        string memory _name,
        string memory _description,
        string memory _imagePointer,
        string memory _metadata,
        uint256 _supply
    )
        external
        onlyMinter(msg.sender)
    {
        uint256 id = ++classIds;
        totalClassesSupply += _supply;

        classes[id] = Structs.Class(id, _supply, 0, _name, _description, _imagePointer, _metadata);

        emit ClassAdded(id, _metadata);
    }

    /**
     * @notice Returns all classes
     */
    function getAllClasses() public view returns (Structs.Class[] memory) {
        Structs.Class[] memory _classes = new Structs.Class[](classIds);

        for (uint256 i = 0; i < classIds; i++) {
            _classes[i] = classes[i + 1];
        }

        return _classes;
    }

    /**
     * @notice Updates the token metadata
     * @dev This function is only callable by staff - only use if you really need to
     * @param _tokenId The token ID to update
     * @param _classId The class ID
     * @param _newTokenURI The new token URI 🚨 must be a pointer to a json object 🚨
     * @return The new token URI
     */
    function updateTokenMetadata(
        uint256 _classId,
        uint256 _tokenId,
        string memory _newTokenURI
    )
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (string memory)
    {
        if (super.ownerOf(_tokenId) != address(0)) {
            _setTokenURI(_tokenId, _newTokenURI);

            emit TokenMetadataUpdated(msg.sender, _classId, _tokenId, tokenURI(_tokenId));

            return tokenURI(_tokenId);
        } else {
            revert Errors.InvalidTokenId(_tokenId);
        }
    }

    /**
     * @notice Sets the class token supply
     * @dev This function is only callable by staff
     * @param _classId The class ID
     * @param _supply The new supply
     */
    function setClassTokenSupply(uint256 _classId, uint256 _supply) external onlyMinter(msg.sender) {
        uint256 currentSupply = classes[_classId].supply;
        uint256 minted = classes[_classId].minted;

        if (_supply < currentSupply) {
            // if the new supply is less than the current supply, we need to check if the new supply is less than the
            // minted
            // if it is, then we need to revert
            if (_supply < minted) {
                revert Errors.NewSupplyTooLow(minted, _supply);
            }
        }

        // update the total supply
        totalClassesSupply = totalClassesSupply - currentSupply + _supply;
        classes[_classId].supply = _supply;

        emit UpdatedClassTokenSupply(_classId, _supply);
    }

    /**
     * View Functions ******
     */

    /**
     * @notice Returns the total supply for a class
     * @param _classId The class ID
     */
    function getTotalSupplyForClass(uint256 _classId) external view returns (uint256) {
        return classes[_classId].supply;
    }

    /**
     * @notice Returns the total supply for all classes
     */
    function getTotalSupplyForAllClasses() external view returns (uint256) {
        return totalClassesSupply;
    }

    /**
     * @notice Returns `_baseURI` for the `tokenURI`
     */
    function _baseURI() internal pure override returns (string memory) {
        // TODO: 🚨 update this when production ready 🚨
        return string.concat("https://pharo.mypinata.cloud/ipfs/QmSnzdnhtCuJ6yztHmtYFT7eU2hFF17QNM6rsNohFn6csg/");
    }

    /**
     * @notice Returns the `tokenURI`
     * @param _classId The class ID
     * @param _tokenId The token ID
     */
    function getTokenURI(uint256 _classId, uint256 _tokenId) public pure returns (string memory) {
        string memory classId = Strings.toString(_classId);
        string memory tokenId = Strings.toString(_tokenId);

        return string.concat(classId, "/", tokenId, ".json");
    }

    /**
     * @notice Returns the owner of the token
     * @param _tokenId The token ID
     */
    function getOwnerOfToken(uint256 _tokenId) external view returns (address) {
        return super.ownerOf(_tokenId);
    }

    /**
     * Internal Functions ******
     */

    /**
     * @notice Mints a new campaign item
     * @param _recipient The recipient of the item
     * @param _classId The class ID
     */
    function _mintItem(address _recipient, uint256 _classId) internal returns (uint256) {
        uint256 tokenId = ++_tokenIds;

        // update the class minted count
        classes[_classId].minted++;

        _safeMint(_recipient, tokenId);
        _setTokenURI(tokenId, getTokenURI(_classId, tokenId));

        return tokenId;
    }

    /**
     * Overrides
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable, ERC721Votes)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Votes)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
