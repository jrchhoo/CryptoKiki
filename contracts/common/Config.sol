// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Config is Ownable {

    event SetBytes32(bytes key, bytes32 value);
    event SetUint256(bytes key, uint256 value);
    event SetBool(bytes key, bool value);
    event SetAddress(bytes key, address value);
    event SetUintArray(bytes key, uint[] values);
    event SetAddressArray(bytes key, address[] values);
    
    mapping(bytes => bytes32) public keyToBytes32;
    mapping(bytes => uint256) public keyToUint256;
    mapping(bytes => bool) public keyToBool;
    mapping(bytes => address) public keyToAddress;
    mapping(bytes => uint[]) public keyToUintArray;
    mapping(bytes => address[]) public keyToAddressArray;

    function setBytes32(bytes memory _key, bytes32 _value) external onlyOwner {
        keyToBytes32[_key] = _value;
        emit SetBytes32(_key, _value);
    }

    function setUint256(bytes memory _key, uint256 _value) external onlyOwner {
        keyToUint256[_key] = _value;
        emit SetUint256(_key, _value);
    }

    function setBool(bytes memory _key, bool _value) external onlyOwner {
        keyToBool[_key] = _value;
        emit SetBool(_key, _value);
    }

    function setAddress(bytes memory _key, address _value) external onlyOwner {
        keyToAddress[_key] = _value;
        emit SetAddress(_key, _value);
    }

    function setUintArray(bytes memory _key, uint[] memory _values) external onlyOwner {
        keyToUintArray[_key] = _values;
        emit SetUintArray(_key, _values);
    }

    function setAddressArray(bytes memory _key, address[] memory _values) external onlyOwner {
        keyToAddressArray[_key] = _values;
        emit SetAddressArray(_key, _values);
    }
}
