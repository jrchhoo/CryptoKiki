// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Config is Ownable {

    event SetBytes32(bytes32 key, bytes32 value);
    event SetUint256(bytes32 key, uint256 value);
    event SetBool(bytes32 key, bool value);
    event SetAddress(bytes32 key, address value);
    event SetUintArray(bytes32 key, uint[] values);
    event SetAddressArray(bytes32 key, address[] values);
    
    mapping(bytes32 => bytes32) public keyToBytes32;
    mapping(bytes32 => uint256) public keyToUint256;
    mapping(bytes32 => bool) public keyToBool;
    mapping(bytes32 => address) public keyToAddress;
    mapping(bytes32 => uint[]) public keyToUintArray;
    mapping(bytes32 => address[]) public keyToAddressArray;

    function setBytes32(bytes32 _key, bytes32 _value) external onlyOwner {
        keyToBytes32[_key] = _value;
        emit SetBytes32(_key, _value);
    }

    function setUint256(bytes32 _key, uint256 _value) external onlyOwner {
        keyToUint256[_key] = _value;
        emit SetUint256(_key, _value);
    }

    function setBool(bytes32 _key, bool _value) external onlyOwner {
        keyToBool[_key] = _value;
        emit SetBool(_key, _value);
    }

    function setAddress(bytes32 _key, address _value) external onlyOwner {
        keyToAddress[_key] = _value;
        emit SetAddress(_key, _value);
    }

    function setUintArray(bytes32 _key, uint[] memory _values) external onlyOwner {
        keyToUintArray[_key] = _values;
        emit SetUintArray(_key, _values);
    }

    function setAddressArray(bytes32 _key, address[] memory _values) external onlyOwner {
        keyToAddressArray[_key] = _values;
        emit SetAddressArray(_key, _values);
    }
}
