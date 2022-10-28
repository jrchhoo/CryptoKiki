// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "../interfaces/IKikiNft.sol";
import "../interfaces/IConfig.sol";
import "../libraries/LibConstants.sol";

/**
 * @title KikiBlindBox
 * @author Will Hoo
 */
contract KikiBlindBox is
    Ownable,
    VRFConsumerBaseV2,
    ERC721Burnable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    error OnlyLessThanMaxSupplyCanMint(address _to, uint8 _count);
    error OnlyLessThanUserLimitCanMint(address _to, uint256 _count);
    error OnlyValidBoxCanOpen(address _to, uint256 _token);
    error OnlyValidTokenCanBuy(address _to, address _token);
    error OnlyValidPriceCanBuy(address _to);

    event Buy(address from, address token, uint256 price, uint8 count);
    event Open(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed requestId
    );
    event OpenBack(
        address indexed from,
        uint256 indexed tokenId,
        bool indexed isSuccess
    );

    uint32 public constant VRF_CALLBACK_GAS_LIMIT = 200000;
    uint16 public constant VRF_REQUEST_CONFIRMATIONS = 3;
    uint32 public constant VRF_NUM_WORDS = 1;

    string public baseURI;
    uint256 public sold;

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
        uint256 price;
        address[] supportTokens;
    }
    mapping(address => KikiBox) kikiBoxes;
    mapping(address => uint8) purchases;

    constructor(
        address _kikiNft_,
        address _config_,
        address _vrfCoordinator_,
        bytes32 _keyHash,
        uint32 _subscriptionId,
        string memory _baseURI
    ) ERC721("Kiki Blind Box", "KikiBox") VRFConsumerBaseV2(_vrfCoordinator_) {
        keyHash = _keyHash;
        s_subscriptionId = _subscriptionId;
        baseURI = _baseURI;
        _kikiNft = IKikiNft(_kikiNft_);
        _vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator_);
        _config = IConfig(_config_);
        address[] memory _supportTokens = new address[](1);
        _supportTokens[0] = _config.keyToAddress(LibConstants.KKT);
        _setKikiBoxes(50, 100e18, _supportTokens);
    }

    function setKikiBoxes(
        uint8 _limit,
        uint256 _price,
        address[] memory _supportTokens
    ) external onlyOwner {
        _setKikiBoxes(_limit, _price, _supportTokens);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address caller = _requestIdToCaller[requestId];
        uint256 tokenId = _requestIdToTokenId[requestId];
        uint256 newTokenId = _kikiNft.mint(caller, randomWords[0]);
        bool isSuccess;
        if (newTokenId != 0) {
            _burn(tokenId);
            isSuccess = true;
        } else {
            transferFrom(address(this), caller, tokenId);
        }
        emit OpenBack(caller, newTokenId, isSuccess);
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
        emit Open(sender, _tokenId, requestId);
    }

    function buy(address _token, uint8 _count) external nonReentrant {
        address sender = _msgSender();
        if (_count == 0 || sold.add(_count) > _kikiNft.getMaxSupply()) {
            revert OnlyLessThanMaxSupplyCanMint(sender, _count);
        }
        if (!isTokenSupport(_token)) {
            revert OnlyValidTokenCanBuy(sender, _token);
        }
        if (!isRemainderEnough(sender, _count)) {
            revert OnlyLessThanUserLimitCanMint(sender, _count);
        }
        _tokenIdTracker.increment();
        uint256 newTokenId = _tokenIdTracker.current();
        for (uint8 i = 0; i < _count; i++) {
            _safeMint(sender, newTokenId);
        }
        sold += _count;
        purchases[sender] += _count;
        uint256 _price = kikiBoxes[address(_kikiNft)].price;
        _pay(sender, _token, _price, _count);
        emit Buy(sender, _token, _price, _count);
    }

    function _setKikiBoxes(
        uint8 _limit,
        uint256 _price,
        address[] memory _supportTokens
    ) private {
        kikiBoxes[address(_kikiNft)] = KikiBox({
            limit: _limit,
            price: _price,
            supportTokens: _supportTokens
        });
    }

    function _pay(
        address _from,
        address _token,
        uint256 _price,
        uint8 _count
    ) private {
        address receiver = _config.keyToAddress(LibConstants.RECEIVER);
        IERC20(_token).safeTransferFrom(_from, receiver, _price.mul(_count));
    }

    function isTokenSupport(address _token) public view returns (bool) {
        address[] memory _supportTokens = kikiBoxes[address(_kikiNft)]
            .supportTokens;
        if (_supportTokens.length == 0) {
            return false;
        }
        for (uint8 i = 0; i < _supportTokens.length; i++) {
            if (_token == _supportTokens[i]) {
                return true;
            }
        }
        return false;
    }

    function isRemainderEnough(address _sender, uint8 _count)
        public
        view
        returns (bool)
    {
        uint8 purchase = purchases[_sender];
        if (purchase + _count <= kikiBoxes[address(_kikiNft)].limit) {
            return true;
        }
        return false;
    }
}
