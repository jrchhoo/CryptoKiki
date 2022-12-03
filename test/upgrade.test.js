const { expect } = require('chai');
const {deployments} = require('hardhat');

const setup = deployments.createFixture(
    async ({deployments, ethers, getNamedAccounts}) => {
        const {deployer, upgradeAdmin} = await getNamedAccounts();
        await deployments.deployProxy('DemoV1', {
            from: deployer,
            proxy: {
                owner: upgradeAdmin,
                proxyContract: 'OpenZeppelinTransparentProxy',
                execute: {
                    methodName: 'initialize',
                    args: [10, 'hello', 18],
                },
                upgradeIndex: 0,
            },
            log: true,
        });
        const result = await deployments.read('DemoV1', 'users', 1);
        console.log(result.toString());
        expect(await deployments.read('DemoV1', 'old')).to.be.equal(1);
        return {
            DemoV1: await ethers.getContract('DemoV1'),
            deployer,
            upgradeAdmin,
        };
    }
);

describe('upgrade-validation', () => {
    it('should upgrade successful', async () => {
        const {deployer, upgradeAdmin} = await setup();
        await deployments.deployProxy('DemoV1', {
            from: deployer,
            contract: 'DemoV2',
            proxy: {
                owner: upgradeAdmin,
                proxyContract: 'OpenZeppelinTransparentProxy',
                execute: {
                    methodName: 'initializeV2',
                    args: [1000],
                },
                upgradeIndex: 1,
            },
            log: true,
        });

        const result = await deployments.read('DemoV1', 'users', 1);
        console.log(result.toString());

        expect(await deployments.read('DemoV1', 'old')).to.be.equal(2);
        expect(await deployments.read('DemoV1', 'version')).to.be.equal(1000);
    });

});