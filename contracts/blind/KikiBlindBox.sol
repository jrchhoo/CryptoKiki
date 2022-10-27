// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "../interfaces/IKikiNft.sol";
import "../interfaces/IConfig.sol";

/**
 * @title Lib
 * @author Will Hoo
 */
contract KikiBlindBox is VRFConsumerBaseV2, ERC721Burnable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    error OnlyLessThanMaxSupplyCanMint(address _to, uint256 _count);
    error OnlyValidBoxCanOpen(address _to, uint256 _token);

    uint32 public constant VRF_CALLBACK_GAS_LIMIT = 200000;
    uint16 public constant VRF_REQUEST_CONFIRMATIONS = 3;
    uint32 public constant VRF_NUM_WORDS = 1;

    string public baseURI;
    uint256 public sold;
    address public receiver;

    bytes32 public keyHash;
    uint32 public s_subscriptionId;

    mapping(uint256 => address) private _requestIdToCaller;
    mapping(uint256 => uint256) private _requestIdToTokenId;

    Counters.Counter private _tokenIdTracker;
    IKikiNft private _kikiNft;
    IConfig private _config;
    VRFCoordinatorV2Interface private _vrfCoordinator;

    struct KikiBox {
        uint8 limit;
        uint256 usdtPrice;
        address[] supportTokens;
    }
    mapping(address => KikiBox) kikiBoxs;

    constructor(
        address _receiver,
        address _kikiNft_,
        address _config_,
        address _vrfCoordinator_,
        bytes32 _keyHash,
        uint32 _subscriptionId,
        string memory _baseURI
    ) ERC721("Kiki Blind Box", "KikiBox") VRFConsumerBaseV2(_vrfCoordinator_) {
        receiver = _receiver;
        keyHash = _keyHash;
        s_subscriptionId = _subscriptionId;
        baseURI = _baseURI;
        _kikiNft = IKikiNft(_kikiNft_);
        _vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator_);
        _config = IConfig(_config_);
        address[] memory _supportTokens = new address[](3);
        _supportTokens[0] = _config.keyToAddress(bytes("BNB"));
        _supportTokens[1] = _config.keyToAddress(bytes("USDT"));
        _supportTokens[2] = _config.keyToAddress(bytes("KKT"));
        _setKikiBoxes(20, 10e18, _supportTokens);
    }

    function setKikiBoxes(
        uint8 _limit,
        uint256 _usdtPrice,
        address[] memory _supportTokens
    ) external {
        _setKikiBoxes(_limit, _usdtPrice, _supportTokens);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address caller = _requestIdToCaller[requestId];
        uint256 tokenId = _requestIdToTokenId[requestId];
        uint256 newTokenId = _kikiNft.mint(caller, randomWords[0]);
        if (newTokenId != 0) {
            _burn(tokenId);
        } else {
            transferFrom(address(this), caller, tokenId);
        }
    }

    function open(uint256 _tokenId) external nonReentrant {
        address sender = _msgSender();
        if (!_exists(_tokenId)) {
            revert OnlyValidBoxCanOpen(sender, _tokenId);
        }
        if (ownerOf(_tokenId) != sender) {
            revert OnlyValidBoxCanOpen(sender, _tokenId);
        }
        uint256 requestId = _vrfCoordinator.requestRandomWords(
            keyHash,
            s_subscriptionId,
            VRF_REQUEST_CONFIRMATIONS,
            VRF_CALLBACK_GAS_LIMIT,
            VRF_NUM_WORDS
        );
        safeTransferFrom(sender, address(this), _tokenId);
        _requestIdToCaller[requestId] = sender;
        _requestIdToTokenId[requestId] = _tokenId;
    }

    function buy(address _token, uint256 _count) external nonReentrant {
        address sender = _msgSender();
        if (_count == 0 || _count.add(sold) > _kikiNft.maxSupply()) {
            revert OnlyLessThanMaxSupplyCanMint(sender, _count);
        }
        _tokenIdTracker.increment();
        uint256 newTokenId = _tokenIdTracker.current();
        _safeMint(sender, newTokenId);
        IERC20(_token).safeTransferFrom(sender, receiver, 10e18);
    }

    function _setKikiBoxes(
        uint8 _limit,
        uint256 _usdtPrice,
        address[] memory _supportTokens
    ) private {
        kikiBoxs[address(_kikiNft)] = KikiBox({
            limit: _limit,
            usdtPrice: _usdtPrice,
            supportTokens: _supportTokens
        });
    }
}
