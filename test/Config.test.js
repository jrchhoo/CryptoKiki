const {
    ensureOnlyExpectedMutativeFunctions,
    onlyGivenAddressCanInvoke,
    getAccounts,
    getContract,
    withSnapshot,
    ethers,
    expect,
} = require("./common");

const setup = withSnapshot(["Config"], async () => {
    const contracts = {
        config: await getContract("Config"),
    };
    const accounts = await getAccounts();
    return {
        ...contracts,
        ...accounts,
    };
});

const stringToBytes32 = (key) => {
    return ethers.utils.id(key);
};

describe("Config Test", () => {
    let config;
    let owner;

    beforeEach(async () => {
        ({ config, owner } = await setup());
    });

    it("ensure only known functions are mutative", () => {
        ensureOnlyExpectedMutativeFunctions({
            abi: config.abi,
            ignoreParents: ["Ownable"],
            expected: [
                "setBytes32",
                "setUint256",
                "setBool",
                "setAddress",
                "setUintArray",
                "setAddressArray",
            ],
        });
    });

    describe("constractor()", async () => {
        it("should return correct owner", async () => {
            expect(await config.owner()).to.be.equal(owner.address);
        });

        it("should return correct receiver", async () => {
            expect(
                await config.keyToAddress(ethers.utils.id("RECEIVER"))
            ).to.be.equal(owner.address);
        });
    });

    describe("Function permissions", async () => {
        [
            {
                method: "setBytes32",
                key: "keyToBytes32",
                value: stringToBytes32("bytes32value"),
            },
            {
                method: "setUint256",
                key: "keyToUint256",
                value: 121341234,
            },
            {
                method: "setBool",
                key: "keyToBool",
                value: true,
            },
            {
                method: "setAddress",
                key: "keyToAddress",
                value: "0xA2959D3F95eAe5dC7D70144Ce1b73b403b7EB6E0",
            },
            {
                method: "setUintArray",
                key: "keyToUintArray",
                value: [123, 45, 789, 10],
            },
            {
                method: "setAddressArray",
                key: "keyToAddressArray",
                value: [
                    "0xA2959D3F95eAe5dC7D70144Ce1b73b403b7EB6E0",
                    "0x36dE7f91c0015172985071Bf42fA4D4b87b80a50",
                ],
            },
        ].forEach(({ method, key, value }) => {
            it(`only owner can ${method}`, async () => {
                const bytes32Key = stringToBytes32(key);
                await onlyGivenAddressCanInvoke({
                    instance: config,
                    fnc: method,
                    args: [bytes32Key, value],
                    signer: owner,
                });
            });
        });
    });

    describe("setConfig and getConfig()", async () => {
        [
            {
                method: "setBytes32",
                key: "keyToBytes32",
                value: stringToBytes32("bytes32value"),
            },
            {
                method: "setUint256",
                key: "keyToUint256",
                value: 121341234,
            },
            {
                method: "setBool",
                key: "keyToBool",
                value: true,
            },
            {
                method: "setAddress",
                key: "keyToAddress",
                value: "0xA2959D3F95eAe5dC7D70144Ce1b73b403b7EB6E0",
            },
            {
                method: "setUintArray",
                key: "keyToUintArray",
                value: [123, 45, 789, 10],
            },
            {
                method: "setAddressArray",
                key: "keyToAddressArray",
                value: [
                    "0xA2959D3F95eAe5dC7D70144Ce1b73b403b7EB6E0",
                    "0x36dE7f91c0015172985071Bf42fA4D4b87b80a50",
                ],
            },
        ].forEach(({ method, key, value }) => {
            it(`if set method is ${method}, value should set and get success`, async () => {
                const bytes32Key = stringToBytes32(key);
                await config.connect(owner)[`${method}`](bytes32Key, value);
                if (method === "setUintArray" || method === "setAddressArray") {
                    const length = value.length;
                    for (let i = 0; i < length; i++) {
                        expect(
                            await config[`${key}`](bytes32Key, i)
                        ).to.be.equal(value[i]);
                    }
                } else {
                    expect(await config[`${key}`](bytes32Key)).to.be.equal(
                        value
                    );
                }
            });
        });
    });
});
