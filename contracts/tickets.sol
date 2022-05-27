// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract tickets is ERC721URIStorage, VRFConsumerBase, Ownable {
  
  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;
  address public VRFCoordinator;
  address public LinkToken;

  struct ticket {
    string from; // departure location
    string to;
    string class; // economy, business, first class etc
    uint256 travelers; // no. of
    string carrier;
    string departureDateTime;
    string arrivalDateTime;
    uint256 price;
    uint256 id; // flight id
    string imgUrl; // need to follow filecoin example to store on nft.storage
    address booker;
  }

  ticket[] public tickets;

  // mapping(bytes32 => string) public requestToTicketId;
  mapping(bytes32 => address) requestToSender;
  mapping(bytes32 => uint256) requestToTokenId;

  event requestedTicket(bytes32 indexed requestId);

  /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, address _priceFeed)
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("DungeonsAndDragonsCharacter", "D&D")
    {   
        VRFCoordinator = _VRFCoordinator;
        priceFeed = AggregatorV3Interface(_priceFeed);
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    function requestNewTicket(string memory name) public returns (bytes32) {
      require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
      bytes32 requestId = requestRandomness(keyHash, fee);
      // requestToCharacterName[requestId] = name;
      requestToSender[requestId] = msg.sender;
      emit requestedTicket(requestId);
      return requestId;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
      return tokenURI(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
      _setTokenURI(tokenId, _tokenURI);
    }

    // function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
    //     internal
    //     override
    // {
    //     uint256 newId = characters.length;
    //     int256 strength = (getLatestPrice() / 10000000000);
    //     uint256 dexterity = randomNumber % 100;
    //     uint256 constitution = uint256(keccak256(abi.encode(randomNumber, 1))) % 100;
    //     uint256 intelligence = uint256(keccak256(abi.encode(randomNumber, 2))) % 100;
    //     uint256 wisdom = uint256(keccak256(abi.encode(randomNumber, 3))) % 100;
    //     uint256 charisma = uint256(keccak256(abi.encode(randomNumber, 4))) % 100;
    //     uint256 experience = 0;
    //     Character memory character = Character(
    //             strength,
    //             dexterity,
    //             constitution,
    //             intelligence,
    //             wisdom,
    //             charisma,
    //             experience,
    //             requestToCharacterName[requestId]);
    //     characters.push(character);
    //     _safeMint(requestToSender[requestId], newId);
    // }

    function getNumberOfTickets() public view returns (uint256) {
      return tickets.length; 
    }

    // function getCharacterOverView(uint256 tokenId)
    //     public
    //     view
    //     returns (
    //         string memory,
    //         uint256,
    //         uint256,
    //         uint256
    //     )
    // {
    //     return (
    //         characters[tokenId].name,
    //         uint(characters[tokenId].strength) + characters[tokenId].dexterity + characters[tokenId].constitution + characters[tokenId].intelligence + characters[tokenId].wisdom + characters[tokenId].charisma,
    //         getLevel(tokenId),
    //         characters[tokenId].experience
    //     );
    // }

    

}