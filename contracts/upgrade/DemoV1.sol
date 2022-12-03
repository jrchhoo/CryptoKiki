// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract DemoV1 is Initializable{
    struct User{
        uint256 id;
        string name;
        uint8 age;
    }

    uint256 public old;
    mapping (uint256 => User) public users;

    function initialize(uint256 _id, string memory _name, uint8 _age) initializer public {
        users[1] = User({
            id: _id,
            name: _name,
            age: _age
        });
        old = 1;
    }
    
}