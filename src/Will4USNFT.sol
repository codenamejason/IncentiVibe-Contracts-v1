// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice This contract is the Main NFT contract for the Will 4 US Campaign
/// @dev This contract is used to mint NFTs for the Will 4 US Campaign
/// @author @codenamejason <jax@jaxcoder.xyz>
contract Will4USNFT is ERC721URIStorage, Ownable {
    /**
     * State Variables ********
     */
    uint256 private _tokenIds = 1;
    uint256 public classIds = 1;
    uint256 public MAX_MINTABLE_PER_CLASS;

    mapping(uint256 => Class) public classes;
    mapping(address => bool) public campaignMembers;
    mapping(address => mapping(uint256 => uint256)) public mintedPerClass;

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
    error MaxMintablePerClassReached(uint256 classId, uint256 maxMintable);

    /**
     * Events ************
     */
    event ItemAwarded(uint256 indexed tokenId, address indexed recipient, uint256 indexed classId);
    event TokenMetadataUpdated(address indexed sender, uint256 indexed tokenId, string tokenURI);
    event CampaignMemberAdded(address indexed member);
    event CampaignMemberRemoved(address indexed member);
    event ClassAdded(uint256 indexed classId, string metadata);

    /**
     * Modifiers ************
     */

    /**
     * @notice Checks if the sender is a campaign member
     * @dev This modifier is used to check if the sender is a campaign member
     * @param sender The sender address
     */
    modifier onlyCampaingnMember(address sender) {
        require(campaignMembers[sender], "Only campaign members can call this function");
        _;
    }

    /**
     * Constructor *********
     */
    constructor(address owner) ERC721("Will 4 US NFT Collection", "WILL4USNFT") Ownable(owner) {
        // add the owner to the campaign members
        campaignMembers[owner] = true;

        MAX_MINTABLE_PER_CLASS = 5;

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
     * @param _tokenURI The token uri
     * @param _classId The class ID
     */
    function awardCampaignItem(address _recipient, string memory _tokenURI, uint256 _classId)
        external
        onlyCampaingnMember(msg.sender)
        returns (uint256)
    {
        if (mintedPerClass[_recipient][_classId] > MAX_MINTABLE_PER_CLASS) {
            revert MaxMintablePerClassReached(_classId, MAX_MINTABLE_PER_CLASS);
        }

        uint256 tokenId = _mintCampaingnItem(_recipient, _tokenURI, _classId);
        mintedPerClass[_recipient][_classId]++;

        emit ItemAwarded(tokenId, _recipient, _classId);

        return tokenId;
    }

    /**
     * @notice Awards campaign nft to a batch of supporters
     * @dev This function is only callable by campaign members
     * @param _recipients The recipients of the item
     * @param _tokenURIs The token uris
     * @param _classIds The class IDs
     */
    function batchAwardCampaignItem(
        address[] memory _recipients,
        string[] memory _tokenURIs,
        uint256[] memory _classIds
    ) external onlyCampaingnMember(msg.sender) returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](_recipients.length);

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (mintedPerClass[_recipients[i]][_classIds[i]] > MAX_MINTABLE_PER_CLASS) {
                revert("You have reached the max mintable for this class");
            }

            tokenIds[i] = _mintCampaingnItem(_recipients[i], _tokenURIs[i], _classIds[i]);
            mintedPerClass[_recipients[i]][_classIds[i]]++;

            emit ItemAwarded(tokenIds[i], _recipients[i], _classIds[i]);
        }

        return tokenIds;
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
        uint256 id = classIds++;

        classes[id] = Class(id, _supply, 0, _name, _description, _imagePointer, _metadata);

        emit ClassAdded(id, _metadata);
    }

    /**
     * @notice Updates the token metadata
     * @dev This function is only callable by campaign members
     * @param _tokenId The token ID to update
     * @param _tokenURI The new token uri
     */
    function updateTokenMetadata(uint256 _tokenId, string memory _tokenURI) external onlyCampaingnMember(msg.sender) {
        if (super.ownerOf(_tokenId) != address(0)) {
            _setTokenURI(_tokenId, _tokenURI);

            emit TokenMetadataUpdated(msg.sender, _tokenId, _tokenURI);
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
    function setClassTokenSupply(uint256 _classId, uint256 _supply) external onlyCampaingnMember(msg.sender) {
        classes[_classId].supply = _supply;
    }

    /**
     * @notice Sets the max mintable per wallet
     * @dev This function is only callable by campaign members
     * @param _maxMintable The new max mintable
     */
    function setMaxMintablePerClass(uint256 _maxMintable) external onlyCampaingnMember(msg.sender) {
        MAX_MINTABLE_PER_CLASS = _maxMintable;
    }

    /**
     * View Functions ******
     */

    /**
     * @notice Returns the class
     * @param _id The class ID
     */
    function getClassById(uint256 _id) external view returns (Class memory) {
        return classes[_id];
    }

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
        uint256 totalSupply = 0;

        for (uint256 i = 1; i < classIds; i++) {
            totalSupply += classes[i].supply;
        }

        return totalSupply;
    }

    /**
     * Internal Functions ******
     */

    // NOTE: not sure if we can use baseURI for this since each class will have a different baseURI essentially
    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://gateway.pinata.cloud/ipfs/hash/classId/tokenId";
    // }

    /**
     * @notice Mints a new campaign item
     * @param _recipient The recipient of the item
     * @param _tokenURI The token uri
     * @param _classId The class ID
     */
    function _mintCampaingnItem(address _recipient, string memory _tokenURI, uint256 _classId)
        internal
        returns (uint256)
    {
        uint256 tokenId = _tokenIds++;

        // update the class minted count
        classes[_classId].minted++;

        _safeMint(_recipient, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        return tokenId;
    }

    /**
     * Overrides
     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage) returns (bool) {}

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
