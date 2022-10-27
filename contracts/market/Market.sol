// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IConfig.sol";
import "../libraries/LibConstants.sol";

contract Market is IERC721Receiver, Ownable, ReentrancyGuard {
    event MarketRecord(
        string operation,
        address token,
        uint256 id,
        address from,
        address to,
        address currency,
        uint256 price
    );
    event SetSupportERC721(address token, bool isSupport);
    event SetSupportERC20(address token, bool isSupport);

    struct Commodity {
        address seller;
        address currency;
        uint256 price;
        uint256 timestamp;
    }

    // nft address => token id => Info
    mapping(address => mapping(uint256 => Commodity)) public commodities;

    mapping(address => bool) public supportERC721;
    mapping(address => bool) public supportERC20;

    constructor(address _owner, address _config) {
        IConfig config = IConfig(_config);
        address kiki = config.keyToAddress(LibConstants.KIKI_NFT);
        address kikiBox = config.keyToAddress(LibConstants.KIKI_BOX);
        _setSupportERC721(kiki, true);
        _setSupportERC721(kikiBox, true);
        address kkt = config.keyToAddress(LibConstants.KKT);
        _setSupportERC20(kkt, true);
        _transferOwnership(_owner);
    }

    function setSupportERC721(address _token, bool _isSupport)
        external
        onlyOwner
    {
        _setSupportERC721(_token, _isSupport);
    }

    function setSupportERC20(address _token, bool _isSupport)
        external
        onlyOwner
    {
        _setSupportERC20(_token, _isSupport);
    }

    function sell(
        address _token,
        uint256 _tokenId,
        address _currency,
        uint256 _price
    ) external onlySupportERC20(_currency) onlySupportERC721(_token) {
        require(_tokenId != 0, "Market: nft id should not zero.");
        require(_price != 0, "Market: nft sell price should not zero.");
        address sender = _msgSender();
        commodities[_token][_tokenId] = Commodity({
            seller: sender,
            currency: _currency,
            price: _price,
            timestamp: block.timestamp
        });
        IERC721(_token).safeTransferFrom(sender, address(this), _tokenId);
        emit MarketRecord(
            "Sell",
            _token,
            _tokenId,
            sender,
            address(this),
            _currency,
            _price
        );
    }

    function buy(address _token, uint256 _tokenId)
        external
        onlySupportERC721(_token)
    {
        Commodity memory commodity = commodities[_token][_tokenId];
        require(commodity.timestamp != 0, "Market: nft is not in the Market.");
        address sender = _msgSender();
        delete commodities[_token][_tokenId];
        IERC721(_token).safeTransferFrom(address(this), sender, _tokenId);
        IERC20(commodity.currency).transferFrom(
            sender,
            commodity.seller,
            commodity.price
        );
        emit MarketRecord(
            "Buy",
            _token,
            _tokenId,
            address(this),
            sender,
            commodity.currency,
            commodity.price
        );
    }

    function cancel(address _token, uint256 _tokenId)
        external
        onlySupportERC721(_token)
    {
        Commodity memory commodity = commodities[_token][_tokenId];
        require(commodity.timestamp != 0, "Market: nft is not in the Market.");
        address sender = _msgSender();
        require(
            commodity.seller == sender,
            "Market: nft is not belong to caller."
        );
        delete commodities[_token][_tokenId];
        IERC721(_token).safeTransferFrom(address(this), sender, _tokenId);
        emit MarketRecord(
            "Cancel",
            _token,
            _tokenId,
            address(this),
            sender,
            commodity.currency,
            0
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _setSupportERC721(address _token, bool _isSupport) private {
        supportERC721[_token] = _isSupport;
        emit SetSupportERC721(_token, _isSupport);
    }

    function _setSupportERC20(address _token, bool _isSupport) private {
        supportERC20[_token] = _isSupport;
        emit SetSupportERC20(_token, _isSupport);
    }

    modifier onlySupportERC20(address _token) {
        require(supportERC20[_token], "Market: token is not supported.");
        _;
    }

    modifier onlySupportERC721(address _token) {
        require(supportERC721[_token], "Market: nft is not supported.");
        _;
    }
}
