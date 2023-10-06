// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract Will4USNFT is ERC721URIStorage {
    /**
     * State Variables ********
     */
    uint256 private _tokenIds;

    /**
     * Errors ************
     */
    error InvalidTokenId(uint256 tokenId);

    /**
     * Events ************
     */
    event ItemAwarded(uint256 indexed tokenId, address indexed recipient);

    /**
     * Modifiers ************
     */

    modifier onlyCampaingnMember(address sender) {
        _;
    }

    /**
     * Constructor *********
     */
    constructor(address owner) ERC721("Will 4 US NFT Collection", "WILL4USNFT") {}

    /**
     * Overrides
     */

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage) returns (bool) {}

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * External Functions *****
     */

    function awardCampaignItem(address _recipient, string memory _tokenURI) external onlyCampaingnMember(msg.sender) {
        uint256 tokenId = _mintCampaingnItem(_recipient, _tokenURI);

        emit ItemAwarded(tokenId, _recipient);
    }

    /**
     * Internal Functions ******
     */

    function _mintCampaingnItem(address _recipient, string memory _tokenURI) internal returns (uint256) {
        uint256 tokenId = ++_tokenIds;

        _safeMint(_recipient, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        emit ItemAwarded(tokenId, _recipient);

        return tokenId;
    }
}
