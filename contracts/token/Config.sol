// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Config is Ownable {
    
    mapping(bytes => bytes32) public keyToBytes32;
    mapping(bytes => uint256) public keyToUint256;
    mapping(bytes => bool) public keyToBool;
    mapping(bytes => address) public keyToAddress;
    mapping(bytes => uint[]) public keyToUintArray;
    mapping(bytes => address[]) public keyToAddressArray;

    function setBytes32(bytes memory _key, bytes32 _value) external onlyOwner {
        keyToBytes32[_key] = _value;
    }

    function setUint256(bytes memory _key, uint256 _value) external onlyOwner {
        keyToUint256[_key] = _value;
    }

    function setAddress(bytes memory _key, bool _value) external onlyOwner {
        keyToBool[_key] = _value;
    }

    function setAddress(bytes memory _key, address _value) external onlyOwner {
        keyToAddress[_key] = _value;
    }

    function setUintArray(bytes memory _key, uint[] memory _values) external onlyOwner {
        keyToUintArray[_key] = _values;
    }

    function setAddressArray(bytes memory _key, address[] memory _values) external onlyOwner {
        keyToAddressArray[_key] = _values;
    }
}
