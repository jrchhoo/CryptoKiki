// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Mintable.sol";
import "../libraries/LibMath.sol";
import "../libraries/LibKiki.sol";

contract KikiNft is ERC721Enumerable, Mintable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    error OnlyLessThanMaxSupplyCanMint(address _to, uint256 _count);

    Counters.Counter private _tokenIdTracker;

    string public baseURI;
    uint256 public maxSupply;

    struct Kiki{
        uint8 age;
        uint8 gender;
        uint8 color;
        uint8 rarity;
        LibKiki.Info info;
    }
    mapping (uint256 => Kiki) public kikis;

    struct Rarity {
        uint256 maxCount;
        uint256 minted;
    }
    mapping (uint8 => Rarity) public rarityPools;
    uint256[] public pools;

    constructor(
        address _owner,
        uint256 _maxSupply,
        string memory _baseURI
    ) ERC721("Kiki NFT", "Kiki") {
        baseURI = _baseURI;
        maxSupply = _maxSupply;
        transferOwnership(_owner);
    }

    function mint(address _to, uint256 _random, LibKiki.Info memory _info) public onlyMinter {
        if (totalSupply() >= maxSupply) {
            revert OnlyLessThanMaxSupplyCanMint(_to, 1);
        }
        _tokenIdTracker.increment();
        uint256 newTokenId = _tokenIdTracker.current();
        Kiki memory kiki = _getKiki(_random, _info);
        kikis[newTokenId] = kiki;
        rarityPools[kiki.rarity].minted += 1;
        _safeMint(_to, newTokenId);
        emit Mint(_to);
    }

    function mintBatch(address _to, uint256 _count, uint256 _random, LibKiki.Info[] memory _infos) external onlyMinter {
        if (totalSupply() + _count > maxSupply) {
            revert OnlyLessThanMaxSupplyCanMint(_to, _count);
        }
        uint256 random;
        for (uint256 i = 0; i < _count; i++) {
            random = uint256(keccak256(abi.encode(_random, i)));
            mint(_to, random, _infos[i]);
        }
        emit MintBatch(_to, _count);
    }

    function getRandom() public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(_msgSender(), block.timestamp, block.difficulty)));
    }

    function _getKiki(uint256 _random, LibKiki.Info memory _info) private view returns(Kiki memory) {

        uint256 rarityCount = _random.mod(maxSupply).add(1);
        uint8 _rarity = uint8(LibMath.binary(pools, rarityCount));
        if (rarityPools[_rarity].minted >= rarityPools[_rarity].maxCount) {
            revert OnlyLessThanMaxSupplyCanMint(_msgSender(), 1);
        }
        uint256 random = getRandom();
        uint8 _age = uint8(random.mod(100).add(1));
        uint8 _gender = uint8(random.mod(2));
        uint8 _color = uint8(random.mod(18));
        Kiki memory kiki = Kiki({
            age: _age,
            gender: _gender,
            color: _color,
            rarity: _rarity,
            info: _info
        });
        return kiki;
    }

    function _initPool() private {
        rarityPools[10] =Rarity({maxCount: 20, minted: 0});
        pools.push(20);
        rarityPools[9] = Rarity({maxCount: 50, minted: 0});
        pools.push(50);
        rarityPools[8] = Rarity({maxCount: 80, minted: 0});
        pools.push(80);
        rarityPools[7] = Rarity({maxCount: 150, minted: 0});
        pools.push(150);
        rarityPools[6] = Rarity({maxCount: 300, minted: 0});
        pools.push(300);
        rarityPools[5] = Rarity({maxCount: 500, minted: 0});
        pools.push(500);
        rarityPools[4] = Rarity({maxCount: 900, minted: 0});
        pools.push(900);
        rarityPools[3] = Rarity({maxCount: 1200, minted: 0});
        pools.push(1200);
        rarityPools[2] = Rarity({maxCount: 2400, minted: 0});
        pools.push(2400);
        rarityPools[1] = Rarity({maxCount: 4400, minted: 0});
        pools.push(4400);
    }

    event Mint(address to);
    event MintBatch(address to, uint256 count);
}
