// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@chainlink/src/v0.8/ChainlinkClient.sol";
import "@chainlink/src/v0.8/shared/access/ConfirmedOwner.sol";

/**
 * @title The PersonaAPIConsumer contract
 * @notice An API Consumer contract that makes GET requests to obtain KYC data
 */
contract PersonaAPIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    mapping(address => bool) public isKYCApproved;

    event DataFullfilled(bytes32 requestId, bool isKYCApproved);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Sepolia Testnet details:
     * Link Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }
    /**
     * @notice Creates a Chainlink request to retrieve API response and update the mapping
     *
     * @return requestId - ID of the request
     */

    function requestKYCData() public returns (bytes32 requestId) {
        Chainlink.Request memory request =
            buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        request.add("get", "set url here");

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        // Chainlink node versions prior to 1.0.0 supported this format
        // request.add("path", "RAW.ETH.USD.VOLUME24HOUR");
        request.add("path", "");

        // Sends the request
        return sendChainlinkRequest(request, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, bool _isKYCApproved)
        public
        recordChainlinkFulfillment(_requestId)
    {
        isKYCApproved[address(0)] = _isKYCApproved;

        emit DataFullfilled(_requestId, _isKYCApproved);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }
}
