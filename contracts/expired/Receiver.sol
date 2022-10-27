// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./IReceiver.sol";
import "../libraries/LibConstants.sol";

contract Receiver is AccessControl, ReentrancyGuard, IReceiver {
    event TransactionRecord(
        string method,
        address token,
        address from,
        address to,
        uint256 data
    );
    event AddOperator(address _operator);
    event RemoveOperator(address _operator);
    event SetSupportERC20(address token, bool isSupport);

    mapping(address => bool) public supportERC20;
    mapping(address => bool) public supportERC721;

    constructor(address _owner) {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function setSupportERC20(address _token, bool _isSupport)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        supportERC20[_token] = _isSupport;
        emit SetSupportERC20(_token, _isSupport);
    }

    function addOperator(address _operator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(LibConstants.ERC20_OPERATOR, _operator);
        emit AddOperator(_operator);
    }

    function removeOperator(address _operator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        revokeRole(LibConstants.ERC20_OPERATOR, _operator);
        emit RemoveOperator(_operator);
    }

    function balanceOf(address _token)
        external
        view
        override
        onlySupportERC20(_token)
        returns (uint256)
    {
        return IERC20(_token).balanceOf(address(this));
    }

    function withdraw(
        address _token,
        address _to,
        uint256 _amount
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        onlySupportERC20(_token)
        enoughBalance(_token, _amount)
    {
        IERC20(_token).transfer(_to, _amount);
        emit TransactionRecord("Withdraw", _token, address(this), _to, _amount);
    }

    function deposit(
        address _token,
        address _from,
        uint256 _amount
    ) external override onlySupportERC20(_token) {
        IERC20(_token).transferFrom(_from, address(this), _amount);
        emit TransactionRecord(
            "Deposit",
            _token,
            _from,
            address(this),
            _amount
        );
    }

    function transferERC20(
        address _token,
        address _to,
        uint256 _amount
    )
        external
        override
        onlyRole(LibConstants.ERC20_OPERATOR)
        onlySupportERC20(_token)
        enoughBalance(_token, _amount)
        nonReentrant
    {
        IERC20(_token).transfer(_to, _amount);
        emit TransactionRecord(
            "TransferERC20",
            _token,
            address(this),
            _to,
            _amount
        );
    }

    function transferERC721In(
        address _token,
        address _from,
        uint256 _id
    ) external override onlySupportERC721(_token, _from, _id) {
        IERC721(_token).safeTransferFrom(_from, address(this), _id);
        emit TransactionRecord(
            "TransferERC721In",
            _token,
            _from,
            address(this),
            _id
        );
    }

    function transferERC721Out(
        address _token,
        address _to,
        uint256 _id
    ) external override onlyRole(LibConstants.ERC721_OPERATOR){
        IERC721(_token).safeTransferFrom(address(this), _to, _id);
        emit TransactionRecord(
            "TransferERC721Out",
            _token,
            address(this),
            _to,
            _id
        );
    }

    modifier onlySupportERC20(address _token) {
        require(supportERC20[_token], "Receiver: token is not supported.");
        _;
    }

    modifier onlySupportERC721(
        address _token,
        address _from,
        uint256 _id
    ) {
        require(supportERC721[_token], "Receiver: nft is not supported.");
        _;
    }

    modifier enoughBalance(address _token, uint256 _amount) {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > _amount, "Receiver: token balance is not enough.");
        _;
    }
}
