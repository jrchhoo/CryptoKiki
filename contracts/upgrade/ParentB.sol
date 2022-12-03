
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract ParentB is Initializable {
    uint256 bbb;

    function _parentB_init() internal onlyInitializing {
        bbb = 888;
    }
    
}