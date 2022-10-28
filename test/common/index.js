const {BigNumber} = require('ethers');
const {expect, assert, chai} = require('chai');
const {artifacts, ethers, deployments} = require('hardhat');

const TransparentUpgradeableProxy = require('hardhat-deploy/extendedArtifacts/TransparentUpgradeableProxy.json');


const toWei = ethers.utils.parseEther;
const fromWei = ethers.utils.formatEther;

function getBigNumber(amount, decimals = 18) {
    return BigNumber.from(amount).mul(BigNumber.from(10).pow(decimals));
}

async function getContract(name) {
    const contract = await ethers.getContract(name);
    contract.abi = (await deployments.get(name)).abi;
    return contract;
}

async function setupContract({
    contract,
    mock = undefined,
    forContract = undefined,
    args = [],
    from = undefined,
}) {
    let deployerAccount;
    if (from) {
        deployerAccount = await ethers.getSigner(from.address || from);
    } else {
        [deployerAccount] = await ethers.getSigners();
    }

    const artifact = await ethers.getContractFactory(contract);

    const create = ({constructorArgs}) => {
        return artifact.connect(deployerAccount).deploy(...constructorArgs);
    };

    let instance;
    try {
        instance = await create({
            constructorArgs: args.length > 0 ? args : [],
        });

        await instance.deployed();
        // Show contracts creating for debugging purposes
        if (process.env.DEBUG) {
            console.log(
                'Deployed',
                contract + (forContract ? ' for ' + forContract : ''),
                mock ? 'mock of ' + mock : '',
                'to',
                instance.address
            );
        }
    } catch (err) {
        throw new Error(
            `Failed to deploy ${contract}. Does it have defaultArgs setup?\n\t└─> Caused by ${err.toString()}`
        );
    }

    instance.abi = artifacts.require(contract).abi;
    return instance;
}

async function onlyGivenAddressCanInvoke({
    instance,
    fnc,
    args = [],
    signer = undefined,
    skipPassCheck = false,
    reason = undefined,
}) {
    const accounts = await ethers.getSigners();
    for (const user of accounts) {
        if (user.address === signer.address) {
            continue;
        }

        if (reason) {
            await expect(
                instance.connect(user)[fnc](...args)
            ).to.be.revertedWith(reason);
        } else {
            await expect(instance.connect(user)[fnc](...args)).to.be.reverted;
        }
    }
    if (!skipPassCheck && signer) {
        await instance.connect(signer)[fnc](...args);
    }
}

function ensureOnlyExpectedMutativeFunctions({
    abi,
    hasFallback = false,
    expected = [],
    ignoreParents = [],
}) {
    const removeExcessParams = (abiEntry) => {
        // Clone to not mutate anything processed by truffle
        const clone = JSON.parse(JSON.stringify(abiEntry));
        // remove the signature in the cases where it's in the parent ABI but not the subclass
        delete clone.signature;
        // remove input and output named params
        (clone.inputs || []).map((input) => {
            delete input.name;
            return input;
        });
        (clone.outputs || []).map((input) => {
            delete input.name;
            return input;
        });
        return clone;
    };

    const combinedParentsABI = ignoreParents
        .reduce((memo, parent) => {
            if (parent === 'Proxy') {
                return memo.concat(TransparentUpgradeableProxy.abi);
            } else {
                return memo.concat(artifacts.require(parent).abi);
            }
        }, [])
        .map(removeExcessParams);

    const fncs = abi
        .filter(
            ({type, stateMutability}) =>
                type === 'function' &&
                stateMutability !== 'view' &&
                stateMutability !== 'pure'
        )
        .map(removeExcessParams)
        .filter(
            (entry) =>
                !combinedParentsABI.find(
                    (parentABIEntry) =>
                        JSON.stringify(parentABIEntry) === JSON.stringify(entry)
                )
        )
        .map(({name}) => name);

    assert.strictEqual(
        fncs.sort().toString(),
        expected.sort().toString(),
        'Mutative functions should only be those expected.'
    );

    const fallbackFnc = abi.filter(({type}) => type === 'fallback');

    assert.equal(
        fallbackFnc.length > 0,
        hasFallback,
        hasFallback
            ? 'No fallback function found'
            : 'Fallback function found when not expected'
    );
}

const toUnit = (amount) => BigNumber.from(toWei(amount.toString()));
const fromUnit = (amount) => fromWei(amount);

function withSnapshot(tags, func) {
    return deployments.createFixture(async (env, options) => {
        await deployments.fixture(tags, {
            fallbackToGlobal: false,
            keepExistingDeployments: false,
        });
        return func(env, options);
    });
}

async function getAccounts() {
    const namedAccounts = await ethers.getNamedSigners();
    const users = await ethers.getUnnamedSigners();
    return {...namedAccounts, users};
}

const ADDRESS_ZERO = '0x0000000000000000000000000000000000000000';

module.exports = {
    ADDRESS_ZERO,
    getBigNumber,

    toUnit,
    fromUnit,

    onlyGivenAddressCanInvoke,

    setupContract,
    ensureOnlyExpectedMutativeFunctions,

    getContract,
    withSnapshot,
    getAccounts,
    expect,
    assert,
    ethers
};
