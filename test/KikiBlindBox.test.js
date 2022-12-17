const {
    ensureOnlyExpectedMutativeFunctions,
    getAccounts,
    getContract,
    withSnapshot,
    ethers,
    expect,
    getBigNumber,
} = require("./common");

const setup = withSnapshot(["KikiBlindBox"], async () => {
    const contracts = {
        kiki: await getContract("Kiki"),
        config: await getContract("Config"),
        kikiBlindBox: await getContract("KikiBlindBox"),
    };
    const accounts = await getAccounts();
    return {
        ...contracts,
        ...accounts,
    };
});

describe("Kiki blind box Test", () => {
    let kiki;
    let config;
    let kikiBlindBox;

    beforeEach(async () => {
        ({ kiki, config, kikiBlindBox, owner } = await setup());
    });

    it("ensure only known functions are mutative", () => {
        ensureOnlyExpectedMutativeFunctions({
            abi: kikiBlindBox.abi,
            ignoreParents: ["Ownable", "VRFConsumerBaseV2", "ERC721Burnable", "ReentrancyGuard"],
            expected: [
                'buy',
                'open',
                'setKikiBoxes'
            ],
        });
    });
});
