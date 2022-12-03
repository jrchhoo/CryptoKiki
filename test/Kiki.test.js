const {
    ensureOnlyExpectedMutativeFunctions,
    getAccounts,
    getContract,
    withSnapshot,
    ethers,
    expect,
    getBigNumber,
} = require("./common");

const setup = withSnapshot(["Kiki"], async () => {
    const contracts = {
        kiki: await getContract("Kiki"),
        config: await getContract("Config"),
    };
    const accounts = await getAccounts();
    return {
        ...contracts,
        ...accounts,
    };
});

describe("Kiki ERC20 Test", () => {
    let kiki;
    let config;

    beforeEach(async () => {
        ({ kiki, config, owner } = await setup());
    });

    it("ensure only known functions are mutative", () => {
        ensureOnlyExpectedMutativeFunctions({
            abi: kiki.abi,
            ignoreParents: ["ERC20"],
            expected: [],
        });
    });

    describe("constractor()", async () => {
        it("should return correct name and sympol", async () => {
            expect(await kiki.name()).to.be.equal("Kiki");
            expect(await kiki.symbol()).to.be.equal("KKT");
        });

        it("should return correct receiver balance", async () => {
            const receiverKey = ethers.utils.id("RECEIVER");
            const receiverValue = await config.keyToAddress(receiverKey);
            const balance = await kiki.balanceOf(receiverValue);
            expect(balance).to.be.equal(getBigNumber(1e8));
        });
    });
});
