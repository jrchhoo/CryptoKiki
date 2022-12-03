const {extendEnvironment} = require('hardhat/config');
const {subtask} = require('hardhat/config');
const {
    TASK_COMPILE_SOLIDITY_COMPILE,
} = require('hardhat/builtin-tasks/task-names');

const {
    readValidations,
} = require('@openzeppelin/hardhat-upgrades/dist/utils/validations');
const {
    assertStorageUpgradeSafe,
    assertUpgradeSafe,
    getImplementationAddress,
    getStorageLayout,
    getStorageLayoutForAddress,
    getUnlinkedBytecode,
    getVersion,
    Manifest,
    withValidationDefaults,
} = require('@openzeppelin/upgrades-core');

extendEnvironment((hre) => {
    hre.deployments = {
        ...hre.deployments,
        deployProxy,
    };
});

const getArtifactFromOptions = async function (name, options) {
    let artifact, artifactName;
    const {deployments} = hre;
    if (options.contract) {
        if (typeof options.contract === 'string') {
            artifactName = options.contract;
            artifact = await deployments.getArtifact(artifactName);
        } else {
            artifact = options.contract;
        }
    } else {
        artifactName = name;
        artifact = await deployments.getArtifact(artifactName);
    }
    return {artifact, artifactName};
};

const deployProxy = async function (name, options) {
    const {
        deployments,
        network: {provider},
    } = hre;

    const {artifact} = await getArtifactFromOptions(name, options);
    await openzeppelin_assertIsValidImplementation({
        bytecode: artifact.bytecode,
    });
    const proxyName = name + '_Proxy';
    const implementationName = name + '_Implementation';
    const proxy = await deployments.getOrNull(proxyName);
    if (proxy) {
        await openzeppelin_assertIsValidUpgrade(provider, proxy.address, {
            bytecode: artifact.bytecode,
        });
    }
    await deployments.catchUnknownSigner(deployments.deploy(name, options));
    const deployResult = await deployments.get(name);
    const forking = isForking();
    if (forking) {
        return deployResult;
    }
    const implementation = await deployments.get(implementationName);
    await openzeppelin_saveDeploymentManifest(
        provider,
        await deployments.get(proxyName),
        implementation
    );
    return deployResult;
};

const openzeppelin_assertIsValidUpgrade = async (
    provider,
    proxyAddress,
    newImplementation
) => {
    const {version: newVersion, validations} = await getVersionAndValidations(
        newImplementation
    );
    const manifest = await getManifest(provider);
    const newStorageLayout = getStorageLayout(validations, newVersion);
    const oldStorageLayout = await getStorageLayoutForAddress(
        manifest,
        validations,
        await getImplementationAddress(provider, proxyAddress)
    );
    // This will throw an error if the upgrade is invalid.
    assertStorageUpgradeSafe(
        oldStorageLayout,
        newStorageLayout,
        withValidationDefaults({})
    );
};

const openzeppelin_assertIsValidImplementation = async (implementation) => {
    const requiredOpts = withValidationDefaults({});
    const {version, validations} = await getVersionAndValidations(
        implementation
    );
    // This will throw an error if the implementation is invalid.
    assertUpgradeSafe(validations, version, requiredOpts);
};

const openzeppelin_saveDeploymentManifest = async (
    provider,
    proxy,
    implementation
) => {
    const {version, validations} = await getVersionAndValidations(
        implementation
    );
    const manifest = await getManifest(provider);
    await manifest.addProxy({
        address: proxy.address,
        txHash: proxy.transactionHash,
        kind: 'transparent',
    });
    await manifest.lockedRun(async () => {
        const manifestData = await manifest.read();
        const layout = getStorageLayout(validations, version);
        manifestData.impls[version.linkedWithoutMetadata] = {
            address: implementation.address,
            txHash: implementation.transactionHash,
            layout,
        };
        await manifest.write(manifestData);
    });
};

const isForking = function () {
    return !!process.env['HARDHAT_DEPLOY_FORK'];
};

const getManifest = async function (provider) {
    if (isForking()) {
        const env = process.env['HARDHAT_DEPLOY_FORK'];
        return new Manifest(hre.config.networks[env].chainId);
    } else {
        return Manifest.forNetwork(provider);
    }
};

const getVersionAndValidations = async (implementation) => {
    if (implementation.bytecode === undefined)
        throw Error('No bytecode for implementation');
    // @ts-expect-error `hre` is actually defined globally
    const validations = await readValidations(hre);
    const unlinkedBytecode = getUnlinkedBytecode(
        validations,
        implementation.bytecode
    );
    const version = getVersion(unlinkedBytecode, implementation.bytecode);
    return {
        version,
        validations,
    };
};

subtask(TASK_COMPILE_SOLIDITY_COMPILE, async (args, hre, runSuper) => {
    const {validate, solcInputOutputDecoder} = await import(
        '@openzeppelin/upgrades-core'
    );
    const {writeValidations} = await import(
        '@openzeppelin/hardhat-upgrades/dist/utils/validations.js'
    );
    // TODO: patch input
    const {output, solcBuild} = await runSuper();
    const {isFullSolcOutput} = await import(
        '@openzeppelin/hardhat-upgrades/dist/utils/is-full-solc-output.js'
    );
    if (isFullSolcOutput(output)) {
        const decodeSrc = solcInputOutputDecoder(args.input, output);
        const validations = validate(output, decodeSrc);
        await writeValidations(hre, validations);
    }
    return {output, solcBuild};
});

module.exports = {
    openzeppelin_assertIsValidImplementation,
    openzeppelin_assertIsValidUpgrade,
    openzeppelin_saveDeploymentManifest,
};
