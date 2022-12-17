// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DemoV2 is Initializable{

    struct User{
        uint256 id;
        string name;
        uint8 age;
        uint8 gender;
        bytes32 nationality;
        bool state;
    }

    uint256 public old;
    mapping (uint256 => User) public users;
    uint256 public version;

    function initialize() initializer public {
        old = 1;
    }

    function initializeV2(uint256 v) reinitializer(2) public {
        version = v;
        old = 2;
        users[1].state = true;
    }
}