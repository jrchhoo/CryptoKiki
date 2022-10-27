// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReceiver {
    function balanceOf(address _token) external view returns (uint256);

    function withdraw(
        address _token,
        address _to,
        uint256 _amount
    ) external;

    function deposit(
        address _token,
        address _from,
        uint256 _amount
    ) external;

    function transferERC20(
        address _token,
        address _to,
        uint256 _amount
    ) external;

    function transferERC721In(
        address _token,
        address _from,
        uint256 _id
    ) external;

    function transferERC721Out(
        address _token,
        address _to,
        uint256 _id
    ) external;
}
