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

    uint256 public mintCounter;

    mapping(uint256 => Class) public classes;
    mapping(address => bool) public campaignMembers;

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

        // set the owner address
        _transferOwnership(owner);
    }

    /**
     * External Functions *****
     */

    function addCampaignMember(address _member) external onlyOwner {
        campaignMembers[_member] = true;

        emit CampaignMemberAdded(_member);
    }

    function removeCampaignMember(address _member) external onlyOwner {
        campaignMembers[_member] = false;

        emit CampaignMemberRemoved(_member);
    }

    /**
     * @notice Awards campaign nft to supporter
     */
    function awardCampaignItem(address _recipient, string memory _tokenURI, uint256 _classId)
        external
        onlyCampaingnMember(msg.sender)
        returns (uint256)
    {
        uint256 tokenId = _mintCampaingnItem(_recipient, _tokenURI, _classId);

        emit ItemAwarded(tokenId, _recipient, _classId);

        return tokenId;
    }

    function addClass(
        string memory _name,
        string memory _description,
        string memory _imagePointer,
        string memory _metadata,
        uint256 _supply
    ) external onlyCampaingnMember(msg.sender) {
        uint256 id = classIds++;

        classes[id] =
            Class(id, _supply, 0, _name, _description, _imagePointer, "https://a_new_pointer_to_json_object.io");

        emit ClassAdded(id, _metadata);
    }

    function updateTokenMetadata(uint256 _tokenId, string memory _tokenURI) external onlyCampaingnMember(msg.sender) {
        if (super.ownerOf(_tokenId) != address(0)) {
            _setTokenURI(_tokenId, _tokenURI);

            emit TokenMetadataUpdated(msg.sender, _tokenId, _tokenURI);
        } else {
            revert InvalidTokenId(_tokenId);
        }
    }

    /**
     * View Functions ******
     */

    function getClassById(uint256 _id) external view returns (Class memory) {
        return classes[_id];
    }

    /**
     * Internal Functions ******
     */

    function _mintCampaingnItem(address _recipient, string memory _tokenURI, uint256 _classId)
        internal
        returns (uint256)
    {
        uint256 tokenId = _tokenIds++;
        mintCounter++;

        // update the class minted count
        classes[_classId].minted = classes[_classId].minted++;

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
