// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    // uint256 public volume;

    string carrier;
    string departureDateTime;
    string arrivalDateTime;
    uint256 price;
    
    string private APItoken; // expires every 30min. see https://developers.amadeus.com/self-service/apis-docs/guides/authorization-262
    bytes32 private jobId;
    uint256 private fee;

    event RequestMultipleFulfilled(bytes32 indexed requestId,
        string carrier, string departureDateTime, string arrivalDateTime, uint256 price);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Kovan Testnet details:
     * Link Token: 0xa36085F69e2889c224210F603D836748e7dC0088
     * Oracle: 0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function setAPIToken(string memory token) external {
        APItoken = token;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestData(
            string memory from,
            string memory to,
            string memory departure, // departure date used for searching
            string memory class,
            uint256 travelers,
            uint8 idx
        ) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillMultipleParameters.selector);

        // Set the URL to perform the GET request on
        string memory base = 'https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=';
        string memory reqStr = string(abi.encodePacked(base
            , from , '&destinationLocationCode=' , to , '&departureDate=' , departure
            , '&adults=' , Strings.toString(travelers) , '&travelClass=' , class));
        req.add('get', reqStr);
        req.add('header', string(abi.encodePacked("Authorization: Bearer " , APItoken)));
        req.add('pathCarrier', string(abi.encodePacked("data,",Strings.toString(idx),",itineraries,0,segments,0,carrierCode")));
        req.add('pathDepartureDateTime', string(abi.encodePacked("data,",Strings.toString(idx),",itineraries,0,segments,0,departure,at")));
        req.add('pathArrivalDateTime', string(abi.encodePacked("data,",Strings.toString(idx),",itineraries,0,segments,0,arrival,at")));
        req.add('pathPrice', string(abi.encodePacked("data,",Strings.toString(idx),",price,total")));

        // // Multiply the result to remove decimals
        int256 timesAmount = 10**2;
        req.addInt('times', timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfillMultipleParameters(bytes32 _requestId, string memory _carrier, string memory _departureDateTime, string memory _arrivalDateTime, uint256 _price) public recordChainlinkFulfillment(_requestId) {
        emit RequestMultipleFulfilled(_requestId, _carrier, _departureDateTime, _arrivalDateTime, _price);
        carrier = _carrier;
        departureDateTime = _departureDateTime;
        arrivalDateTime = _arrivalDateTime;
        price = _price;
    }

    function getDataFromOracle(
        string memory from,
        string memory to,
        string memory departure, // departure date used for searching
        string memory class,
        uint256 travelers,
        uint8 idx) public returns (string memory, string memory, string memory, uint256)
    {
        requestData(from, to, departure, class, travelers, idx);
        return (carrier, departureDateTime, arrivalDateTime, price);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}
