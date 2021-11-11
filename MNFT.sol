//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract MNFT is Ownable, ERC1155 {
  constructor(string memory _uri, uint256 amount) ERC1155(_uri) {}

  function transferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount
  ) public virtual {
    safeTransferFrom(from, to, id, amount, "");
  }

  function mint(
    address to,
    uint256 id,
    uint256 amount
  ) public {
    _mint(to, id, amount, "");
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts
  ) public {
    _mintBatch(to, ids, amounts, "");
  }
}
