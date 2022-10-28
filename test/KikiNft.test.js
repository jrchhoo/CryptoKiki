const {
    ADDRESS_ZERO,
    ensureOnlyExpectedMutativeFunctions,
    onlyGivenAddressCanInvoke,
    setupContract,
    getAccounts,
    getContract,
    withSnapshot,
    chai,
    assert,
    ethers,
    expect,
    getBigNumber,
} = require("./common");

const setup = withSnapshot(["KikiNft"], async () => {
    const contracts = {
        kikiNft: await getContract("KikiNft"),
    };
    const accounts = await getAccounts();
    return {
        ...contracts,
        ...accounts,
    };
});

const rarityToCounts = [
    {
        rarity: 10,
        count: 20,
    },
    {
        rarity: 9,
        count: 50,
    },
    {
        rarity: 8,
        count: 80,
    },
    {
        rarity: 7,
        count: 150,
    },
    {
        rarity: 6,
        count: 300,
    },
    {
        rarity: 5,
        count: 500,
    },
    {
        rarity: 4,
        count: 900,
    },
    {
        rarity: 3,
        count: 1200,
    },
    {
        rarity: 2,
        count: 2400,
    },
    {
        rarity: 1,
        count: 4400,
    },
];

describe("Kiki Nft Test", () => {
    let kikiNft;
    let owner;
    let minter1, minter2;

    beforeEach(async () => {
        ({
            kikiNft,
            owner,
            users: [minter1, minter2],
        } = await setup());
    });

    it('ensure only known functions are mutative', () => {
        ensureOnlyExpectedMutativeFunctions({
            abi: kikiNft.abi,
            ignoreParents: [
                'ERC721Enumerable',
                'Ownable'
            ],
            expected: [
                'mint',
                'addMinter',
                'removeMinter',
            ],
        });
    });

    describe("constractor", async () => {
        it("should return correct owner", async () => {
            expect(await kikiNft.owner()).to.be.equal(owner.address);
        });

        it("should return correct name and symbol", async () => {
            expect(await kikiNft.name()).to.be.equal("Kiki NFT");
            expect(await kikiNft.symbol()).to.be.equal("Kiki");
        });

        it("should return correct max supply", async () => {
            const maxSupply = await kikiNft.getMaxSupply();
            assert.equal(maxSupply, 10000);
        });

        rarityToCounts.forEach(({ rarity, count }) => {
            it(`when rarity is ${rarity}, total supply count is ${count}`, async () => {
                const result = await kikiNft.rarityPools(rarity);
                assert.equal(result.maxCount, count);
                assert.equal(result.minted, 0);
                const count_ = await kikiNft.pools(10 - rarity);
                assert.equal(count_, count);
            });
        });
    });
});
