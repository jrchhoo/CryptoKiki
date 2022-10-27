// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Market is IERC721Receiver, Ownable, ReentrancyGuard{

    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    mapping(address => bool) public supportERC721;
    mapping(address => bool) public supportERC20;

    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    function sell(address _token, uint256 _tokenId, address _currency, uint256 _price) external {
        
    }

    function buy(address _token, uint256 _tokenId) external {

    }

    function cancel(address _token, uint256 _tokenId) external {

    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4){
        return this.onERC721Received.selector;
    }

}