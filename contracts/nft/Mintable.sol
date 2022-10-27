// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Mintable is Ownable {

    mapping(address => bool) minters;

    constructor (address _owner) {
        _transferOwnership(_owner);
    }

    function addMinter(address _minter) external onlyOwner {
        minters[_minter] = true;
    }

    function removeMinter(address _minter) external onlyOwner {
        minters[_minter] = false;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Mintable: caller should be minter");
        _;
    }
}
