// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Will4USNFT is ERC721URIStorage {
    /**
     * State Variables ********
     */
    uint256 private tokenIds;

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
    constructor() ERC721("Will 4 US NFT Collection", "WILL4USNFT") {}

    /**
     * External Functions *****
     */

    function awardCampaignItem(address recipient, string memory tokenURI) external onlyCampaingnMember(msg.sender) {
        uint256 tokenId = ++tokenIds;

        _mintCampaingnItem(recipient, tokenURI);

        emit ItemAwarded(tokenId, recipient);
    }

    /**
     * Internal Functions ******
     */

    function _mintCampaingnItem(address recipient, string memory tokenURI) internal {
        uint256 tokenId = ++tokenIds;

        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        emit ItemAwarded(tokenId, recipient);
    }
}
