// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import { ERC721URIStorage } from
    "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { Strings } from "openzeppelin-contracts/contracts/utils/Strings.sol";

/// @notice This contract is the Main NFT contract for the Will 4 US Campaign
/// @dev This contract is used to mint NFTs for the Will 4 US Campaign
/// @author @codenamejason <jax@jaxcoder.xyz>
contract Will4USNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;
    /**
     * State Variables ********
     */

    uint256 private _tokenIds;
    uint256 public classIds;
    uint256 public totalClassesSupply;
    uint256 public maxMintablePerClass;

    mapping(uint256 => Class) public classes;
    mapping(address => bool) public campaignMembers;
    mapping(address => mapping(uint256 => uint256)) public mintedPerClass;
    mapping(address => mapping(uint256 => bool)) public redeemed;

    struct Class {
        uint256 id;
        uint256 supply; // total supply of this class? do we want this?
        uint256 minted;
        string name;
        string description;
        string imagePointer;
        string metadata; // this is a pointer to json object that contains the metadata for this class
    }

    /**
     * Errors ************
     */
    error InvalidTokenId(uint256 tokenId);
    error MaxMintablePerClassReached(address recipient, uint256 classId, uint256 maxMintable);
    error AlreadyRedeemed(address redeemer, uint256 tokenId);
    error Unauthorized(address sender);
    error NewSupplyTooLow(uint256 minted, uint256 supply);

    /**
     * Events ************
     */
    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(
        address indexed sender, uint256 indexed classId, uint256 indexed tokenId, string tokenURI
    );
    event CampaignMemberAdded(address indexed member);
    event CampaignMemberRemoved(address indexed member);
    event ClassAdded(uint256 indexed classId, string metadata);
    event UpdatedClassTokenSupply(uint256 indexed classId, uint256 supply);
    event UpdatedMaxMintablePerClass(uint256 maxMintable);
    event Redeemed(address indexed redeemer, uint256 indexed tokenId, uint256 indexed classId);

    /**
     * Modifiers ************
     */

    /**
     * @notice Checks if the sender is a campaign member
     * @dev This modifier is used to check if the sender is a campaign member
     * @param sender The sender address
     */
    modifier onlyCampaingnMember(address sender) {
        if (!campaignMembers[sender]) {
            revert Unauthorized(sender);
        }
        _;
    }

    /**
     * Constructor *********
     */
    constructor(address owner, uint256 _maxMintablePerClass)
        ERC721("Will 4 US NFT Collection", "WILL4USNFT")
        Ownable(owner)
    {
        // add the owner to the campaign members
        _addCampaignMember(owner);

        maxMintablePerClass = _maxMintablePerClass;

        // set the owner address
        _transferOwnership(owner);
    }

    /**
     * External Functions *****
     */

    /**
     * @notice Adds a campaign member
     * @dev This function is only callable by the owner
     * @param _member The member to add
     */
    function addCampaignMember(address _member) external onlyOwner {
        _addCampaignMember(_member);
    }

    /**
     * @notice Adds a campaign member
     * @dev This function is internal
     * @param _member The member to add
     */
    function _addCampaignMember(address _member) internal {
        campaignMembers[_member] = true;

        emit CampaignMemberAdded(_member);
    }

    /**
     * @notice Removes a campaign member
     * @dev This function is only callable by the owner
     * @param _member The member to remove
     */
    function removeCampaignMember(address _member) external onlyOwner {
        campaignMembers[_member] = false;

        emit CampaignMemberRemoved(_member);
    }

    /**
     * @notice Awards campaign nft to supporter
     * @dev This function is only callable by campaign members
     * @param _recipient The recipient of the item
     * @param _classId The class ID
     */
    function awardCampaignItem(address _recipient, uint256 _classId)
        external
        onlyCampaingnMember(msg.sender)
        returns (uint256)
    {
        if (mintedPerClass[_recipient][_classId] > maxMintablePerClass) {
            revert MaxMintablePerClassReached(_recipient, _classId, maxMintablePerClass);
        }

        uint256 tokenId = _mintCampaingnItem(_recipient, _classId);
        mintedPerClass[_recipient][_classId]++;

        emit ItemAwarded(tokenId, _recipient, _classId);

        return tokenId;
    }

    /**
     * @notice Awards campaign nft to a batch of supporters
     * @dev This function is only callable by campaign members
     * @param _recipients The recipients of the item
     * @param _classIds The class IDs
     */
    function batchAwardCampaignItem(address[] memory _recipients, uint256[] memory _classIds)
        external
        onlyCampaingnMember(msg.sender)
        returns (uint256[] memory)
    {
        uint256 length = _recipients.length;
        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length;) {
            if (mintedPerClass[_recipients[i]][_classIds[i]] > maxMintablePerClass) {
                revert("You have reached the max mintable for this class");
            }

            tokenIds[i] = _mintCampaingnItem(_recipients[i], _classIds[i]);
            mintedPerClass[_recipients[i]][_classIds[i]]++;

            emit ItemAwarded(tokenIds[i], _recipients[i], _classIds[i]);

            unchecked {
                ++i;
            }
        }

        return tokenIds;
    }

    /**
     * @notice Redeems a campaign item
     * @dev This function is only callable by campaign members
     * @param _tokenId The token ID
     * @param _redeemer The owner/redeemer of the token
     */
    function redeem(uint256 _tokenId, address _redeemer) external onlyCampaingnMember(msg.sender) {
        if (super.ownerOf(_tokenId) == address(0)) {
            revert InvalidTokenId(_tokenId);
        }

        if (redeemed[_redeemer][_tokenId]) {
            revert AlreadyRedeemed(_redeemer, _tokenId);
        }

        redeemed[_redeemer][_tokenId] = true;

        emit Redeemed(_redeemer, _tokenId, classes[_tokenId].id);
    }

    /**
     * @notice Adds a new class to the campaign for issuance
     * @dev This function is only callable by campaign members
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
    ) external onlyCampaingnMember(msg.sender) {
        uint256 id = ++classIds;
        totalClassesSupply += _supply;

        classes[id] = Class(id, _supply, 0, _name, _description, _imagePointer, _metadata);

        emit ClassAdded(id, _metadata);
    }

    /**
     * @notice Returns all classes
     */
    function getAllClasses() public view returns (Class[] memory) {
        Class[] memory _classes = new Class[](classIds);

        for (uint256 i = 0; i < classIds; i++) {
            _classes[i] = classes[i + 1];
        }

        return _classes;
    }

    /**
     * @notice Updates the token metadata
     * @dev This function is only callable by campaign members - only use if you really need to
     * @param _tokenId The token ID to update
     * @param _classId The class ID
     * @param _newTokenURI The new token URI 🚨 must be a pointer to a json object 🚨
     * @return The new token URI
     */
    function updateTokenMetadata(uint256 _classId, uint256 _tokenId, string memory _newTokenURI)
        external
        onlyOwner
        returns (string memory)
    {
        if (super.ownerOf(_tokenId) != address(0)) {
            _setTokenURI(_tokenId, _newTokenURI);

            emit TokenMetadataUpdated(msg.sender, _classId, _tokenId, tokenURI(_tokenId));

            return tokenURI(_tokenId);
        } else {
            revert InvalidTokenId(_tokenId);
        }
    }

    /**
     * @notice Sets the class token supply
     * @dev This function is only callable by campaign members
     * @param _classId The class ID
     * @param _supply The new supply
     */
    function setClassTokenSupply(uint256 _classId, uint256 _supply)
        external
        onlyCampaingnMember(msg.sender)
    {
        uint256 currentSupply = classes[_classId].supply;
        uint256 minted = classes[_classId].minted;

        if (_supply < currentSupply) {
            // if the new supply is less than the current supply, we need to check if the new supply is less than the minted
            // if it is, then we need to revert
            if (_supply < minted) {
                revert NewSupplyTooLow(minted, _supply);
            }
        }

        // update the total supply
        totalClassesSupply = totalClassesSupply - currentSupply + _supply;
        classes[_classId].supply = _supply;

        emit UpdatedClassTokenSupply(_classId, _supply);
    }

    /**
     * @notice Sets the max mintable per wallet
     * @dev This function is only callable by campaign members
     * @param _maxMintable The new max mintable
     */
    function setMaxMintablePerClass(uint256 _maxMintable)
        external
        onlyCampaingnMember(msg.sender)
    {
        maxMintablePerClass = _maxMintable;

        emit UpdatedMaxMintablePerClass(_maxMintable);
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
        return string.concat(
            "https://pharo.mypinata.cloud/ipfs/QmSnzdnhtCuJ6yztHmtYFT7eU2hFF17QNM6rsNohFn6csg/"
        );
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
    function _mintCampaingnItem(address _recipient, uint256 _classId) internal returns (uint256) {
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721URIStorage)
        returns (bool)
    { }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
