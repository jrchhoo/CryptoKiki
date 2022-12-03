// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Mintable.sol";
import "../libraries/LibMath.sol";
import "../interfaces/IKikiNft.sol";

contract KikiNft is ERC721Enumerable, Mintable, IKikiNft {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Strings for uint256;

    event Mint(address to, uint256 tokenId);

    error OnlyLessThanMaxSupplyCanMint(address _to, uint256 _count);

    Counters.Counter private _tokenIdTracker;

    string public baseURI;
    uint256 public maxSupply;

    struct Info {
        bytes3 hair;
        bytes3 face;
        bytes3 eye;
        bytes3 ear;
        bytes3 mouth;
        bytes3 teeth;
        bytes3 neck;
        bytes3 body;
        bytes3 arm;
        bytes3 leg;
        bytes3 foot;
        bytes3 tail;
    }

    struct Kiki {
        uint8 age;
        uint8 gender;
        uint8 rarity;
        Info info;
    }

    mapping(uint256 => Kiki) public kikis;

    struct Rarity {
        uint256 maxCount;
        uint256 minted;
    }
    mapping(uint8 => Rarity) public rarityPools;
    uint256[] public pools;

    constructor(
        address _owner,
        string memory _baseURI_
    ) ERC721("Kiki NFT", "Kiki") {
        baseURI = _baseURI_;
        maxSupply = 10000;
        _initPool();
        transferOwnership(_owner);
    }

    function mint(address _to, uint256 _random)
        public
        override
        onlyMinter
        returns (uint256)
    {
        if (totalSupply() >= maxSupply) {
            revert OnlyLessThanMaxSupplyCanMint(_to, 1);
        }
        _tokenIdTracker.increment();
        uint256 newTokenId = _tokenIdTracker.current();
        Kiki memory kiki = getKiki(_random);
        kikis[newTokenId] = kiki;
        rarityPools[kiki.rarity].minted += 1;
        _safeMint(_to, newTokenId);
        emit Mint(_to, newTokenId);
        return newTokenId;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "token is not exists");
        return string(abi.encodePacked(_baseURI(), _tokenId));
    }

    function getRandom() public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _msgSender(),
                        block.timestamp,
                        block.difficulty
                    )
                )
            );
    }

    function getKiki(uint256 _random) public view returns (Kiki memory) {
        uint256 rarityCount = _random.mod(maxSupply).add(1);
        uint8 _rarity = uint8(LibMath.binary(pools, rarityCount));
        if (rarityPools[_rarity].minted >= rarityPools[_rarity].maxCount) {
            revert OnlyLessThanMaxSupplyCanMint(_msgSender(), 1);
        }
        uint256 random = getRandom();
        uint8 _age = uint8(random.mod(100).add(1));
        uint8 _gender = uint8(random.mod(2));
        Kiki memory kiki = Kiki({
            age: _age,
            gender: _gender,
            rarity: _rarity,
            info: getKikiInfo(_random)
        });
        return kiki;
    }

    function getKikiInfo(uint256 _random) public pure returns (Info memory info) {
        uint256[] memory randomness = new uint256[](12);
        for (uint256 i = 0; i < randomness.length; i++) {
            randomness[i] = uint256(keccak256(abi.encode(_random, i)));
        }
        info = Info({
            hair: getInfoDetail(randomness[0]),
            face: getInfoDetail(randomness[1]),
            eye: getInfoDetail(randomness[2]),
            ear: getInfoDetail(randomness[3]),
            mouth: getInfoDetail(randomness[4]),
            teeth: getInfoDetail(randomness[5]),
            neck: getInfoDetail(randomness[6]),
            body: getInfoDetail(randomness[7]),
            arm: getInfoDetail(randomness[8]),
            leg: getInfoDetail(randomness[9]),
            foot: getInfoDetail(randomness[10]),
            tail: getInfoDetail(randomness[11])
        });
        return info;
    }

    function getInfoDetail(uint256 _random) public pure returns (bytes3) {
        return bytes3(keccak256(abi.encode(_random)));
    }

    function _initPool() private {
        rarityPools[10] = Rarity({maxCount: 20, minted: 0});
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

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function getMaxSupply() external override view returns (uint256){
        return maxSupply;
    }

}
