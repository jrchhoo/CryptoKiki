
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract ParentA is Initializable {
    uint256 aaa;

    function _parentA_init() internal onlyInitializing {
        aaa = 999;
    }
    
}