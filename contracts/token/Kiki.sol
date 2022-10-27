// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IConfig.sol";
import "../libraries/LibConstants.sol";


contract Kiki is ERC20 {

    uint256 public constant MAX_SUPPLY = 1e8*1e18;

    constructor(address _config) ERC20("Kiki", "KKT") {
        address receiver = IConfig(_config).keyToAddress(LibConstants.RECEIVER);
        _mint(receiver, MAX_SUPPLY);
    }
    
}