// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKikiNft {
    
    function maxSupply() external view returns (uint256);

    function mint(address _to, uint256 _random) external returns (uint256);
}
