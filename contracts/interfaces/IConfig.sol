// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface IConfig {

    function keyToBytes32(bytes32 _key) external view returns (bytes32);
    function keyToUint256(bytes32 _key) external view returns (uint256);
    function keyToBool(bytes32 _key) external view returns (bool);
    function keyToAddress(bytes32 _key) external view returns (address);
    function keyToUintArray(bytes32 _key) external view returns (uint[] memory);
    function keyToAddressArray(bytes32 _key) external view returns (address[] memory);
    
}
