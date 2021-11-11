//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./MNFT.sol";
import "hardhat/console.sol";

contract Factory is Ownable {
  using SafeMath for uint256;
  struct Project {
    address projectOwner;
    address nftAddress;
    MNFT nft;
    mapping(uint256 => mapping(address => TokenDetails)) token;
  }

  struct TokenDetails {
    uint128 forSale;
    uint128 price;
  }

  uint256 private projectId;
  uint256 private tokenId;

  mapping(uint256 => Project) public projects;

  event NewProject(
    address indexed creator,
    address indexed projectAddress,
    uint256 indexed projectId,
    uint256 createdAt
  );

  event SellNFT(
    address indexed seller,
    uint256 indexed projectId,
    uint256 tokenID,
    uint128 price,
    uint64 amount
  );

  function createNFT(
    string memory _uri,
    uint256 amount,
    address user
  ) external virtual onlyOwner {
    require(amount > 0, "Factory: Invalid Amount of NFTs");
    MNFT _nft = new MNFT(_uri, amount);
    projects[projectId].nftAddress = address(_nft);
    projects[projectId].nft = _nft;
    projects[projectId].projectOwner = user;
    emit NewProject(user, address(_nft), projectId, block.timestamp);
    projects[projectId].nft.mint(user, tokenId, amount);
    projectId++;
    tokenId++;
  }

  function mintNFT(
    uint64 amount,
    uint256 _projectId,
    address user
  ) external virtual onlyOwner {
    require(amount > 0, "Factory: Invalid Amount of NFTs");
    require(_projectId < projectId, "Factory: Invalid Project Id");
    _mintNFT(amount, _projectId, tokenId, user);
    tokenId++;
  }

  function mintNFTCopies(
    uint64 amount,
    uint256 _projectId,
    uint256 _tokenID,
    address user
  ) external virtual onlyOwner checkParameters(_projectId, _tokenID, amount) {
    _mintNFT(amount, _projectId, _tokenID, user);
  }

  function _mintNFT(
    uint64 amount,
    uint256 _projectId,
    uint256 _tokenID,
    address user
  ) private {
    require(
      (user == projects[_projectId].projectOwner),
      "Factory: Only project owner can mint NFT"
    );
    projects[_projectId].nft.mint(user, _tokenID, amount);
  }

  function sellNFT(
    uint256 _projectId,
    uint256 _tokenID,
    uint128 value,
    uint64 amount,
    address user
  ) external virtual onlyOwner checkParameters(_projectId, _tokenID, amount) {
    require(
      projects[_projectId].nft.balanceOf(user, _tokenID) >= amount,
      "Factory: Not much NFTs yet"
    );
    projects[_projectId].token[_tokenID][user].price = value;
    projects[_projectId].token[_tokenID][user].forSale = amount;
    emit SellNFT(user, _projectId, _tokenID, value, amount);
  }

  function buyNFT(
    uint256 _projectID,
    uint256 _tokenID,
    uint64 amount,
    address seller,
    address user
  )
    external
    payable
    virtual
    onlyOwner
    checkParameters(_projectID, _tokenID, amount)
  {
    MNFT _nft = projects[_projectID].nft;
    require(
      projects[_projectID].token[_tokenID][seller].forSale >= amount,
      "Factory: Cant purchase more then the tokens on sale"
    );
    require(
      amount * projects[_projectID].token[_tokenID][seller].price == msg.value,
      "Factory: Insufficient payment"
    );
    _nft.transferFrom(seller, user, _tokenID, amount);
    payable(seller).transfer((95 * msg.value) / 100);
    projects[_projectID].token[_tokenID][seller].forSale -= amount;
  }

  function getPriceOfNFT(
    uint256 _projectID,
    uint256 _tokenID,
    address user
  ) public view returns (uint256) {
    return projects[_projectID].token[_tokenID][user].price;
  }

  function NFTsForSale(
    uint256 _projectID,
    uint256 _tokenID,
    address user
  ) public view returns (uint256) {
    return projects[_projectID].token[_tokenID][user].forSale;
  }

  function getNFTAddress(uint256 _projectID) public view returns (address) {
    return projects[_projectID].nftAddress;
  }

  modifier checkParameters(
    uint256 _projectId,
    uint256 _tokenID,
    uint64 amount
  ) {
    require(amount > 0, "Factory: Invalid Amount of NFTs");
    require(_projectId < projectId, "Factory: Invalid Project Id");
    require(_tokenID < tokenId, "Factory: Invalid Token Id");
    _;
  }

  function mintBatchNFT(
    uint256[] memory amounts,
    uint256[] memory ids,
    uint256 _projectId,
    address user
  ) external virtual onlyOwner {
    require(_projectId < projectId, "Factory: Invalid Project Id");
    require(
      (user == projects[_projectId].projectOwner),
      "Factory: Only project owner can mint NFTs"
    );
    require(_projectId < projectId, "Factory: Invalid Project Id");
    projects[_projectId].nft.mintBatch(user, ids, amounts);
  }
}
