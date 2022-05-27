// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./APIConsumer.sol";

contract Flights {

  address public owner;
  uint256 private counter;
  AggregatorV3Interface internal priceFeed;
  APIConsumer internal flightAPI;

  constructor() {
      counter = 0;
      owner = msg.sender; // person who deployed this smart contract
      priceFeed = AggregatorV3Interface(0xAA2FE1324b84981832AafCf7Dc6E6Fe6cF124283); // ETH/USD
    }

  struct flightInfo {
      string from; // departure location
      string to;
      string class; // economy, business, first class etc
      uint256 travelers; // no. of
      string carrier;
      string departureDateTime;
      string arrivalDateTime;
      uint256 price;
      uint256 id;
  }

  event flightCreated (
      string from,
      string to,
      string class,
      uint256 travelers,
      string carrier,
      string departureDateTime,
      string arrivalDateTime,
      uint256 price,
      uint256 id
  );

  event newFlightBooked (
    uint256 id,
    address booker
  ); // id refers to flight id

  mapping(uint256 => flightInfo) flights; // ids => flight
  // uint256[] public flightIds;

  /**
    * Returns the latest price
    */
  function getLatestPrice() public view returns (uint) {
      uint res;
      (
          /*uint80 roundID*/,
          int price,
          /*uint startedAt*/,
          /*uint timeStamp*/,
          /*uint80 answeredInRound*/
      ) = priceFeed.latestRoundData();
      if(price < 0) {
          res = uint(-price);
      }
      else {
          res = uint(price);
      }
      return res/(10**8);
  }

  function addFlights( // adds top x relevant flights for search field
    string memory _from,
    string memory _to,
    string memory _departure, // departure date used for searching
    string memory _class,
    uint256 _travelers,
    uint8 topX
  ) public {
    require(msg.sender == owner, "Only owner of smart contract can put up flights for now");
    for (uint8 i = 0; i < topX; i++) {
      (string memory _carrier, string memory _departureDateTime, string memory _arrivalDateTime, uint256 _price) = flightAPI.getDataFromOracle(_from, _to, _departure, _class, _travelers, i);
      flightInfo storage newFlight = flights[counter];
      // set attributes
      newFlight.from = _from;
      newFlight.to = _to;
      newFlight.class = _class;
      newFlight.travelers = _travelers;
      newFlight.carrier = _carrier;
      newFlight.departureDateTime = _departureDateTime;
      newFlight.arrivalDateTime = _arrivalDateTime;
      newFlight.price = SafeMath.div(_price, getLatestPrice());
      newFlight.id = counter;
      // flightIds.push(counter);
      counter++;
      emit flightCreated(_from, _to, _class, _travelers, _carrier, _departureDateTime, _arrivalDateTime, _price, counter-1);
    }
  }

  function bookFlight(uint256 id) public payable {
    require(id < counter, "No such Flight");
    require(msg.value >= (flights[id].price) , "Please submit at least the asking price in order to complete the purchase"); // excess counts as donation
    payable(owner).transfer(msg.value);
    // simulate payment to operator/carrier here. Will be available in future versions.
    emit newFlightBooked(id, msg.sender);
  }

  function getFlight(uint256 id) public view returns (
      string memory,
      string memory,
      string memory,
      uint256,
      string memory,
      string memory,
      string memory,
      uint256,
      uint256
    ) {
    require(id < counter, "No such Flight");
    flightInfo storage s = flights[id];
    return (s.from, s.to, s.class, s.travelers, s.carrier
      , s.departureDateTime, s.arrivalDateTime, s.price, s.id);
  }
}