// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title LibMath
 * @author Will Hoo
 */
library LibMath {

    function binary(uint256[] memory _array, uint256 _target) internal pure returns (uint256) {
        uint256 end = _array.length;
        uint256 start;
        while (start < end) {
            uint256 mid = Math.average(start, end);
            if (_target < _array[mid]) {
                end = mid;
            } else {
                start = mid + 1;
            }
        }
        return end;
    }
}
