const {BigNumber} = require('ethers');
const POINT_ONE_LINK = '100000000000000000';

module.exports = async function ({ethers, getNamedAccounts, deployments}) {
    const {deploy} = deployments;
    const namedAccounts = await getNamedAccounts();
    const {deployer} = namedAccounts;
    await deploy('VRFCoordinatorV2Mock', {
        contract: 'VRFCoordinatorV2Mock',
        from: deployer,
        args: [POINT_ONE_LINK, 1e9],
    });
    const VRFCoordinatorV2Mock = await ethers.getContract(
        'VRFCoordinatorV2Mock'
    );
    const transaction = await VRFCoordinatorV2Mock.createSubscription();
    const transactionReceipt = await transaction.wait(1);
    const subscriptionId = ethers.BigNumber.from(
        transactionReceipt.events[0].topics[1]
    );
    await VRFCoordinatorV2Mock.fundSubscription(
        subscriptionId,
        BigNumber.from('10000000000000000000')
    );
};
module.exports.tags = [
    'VRFCoordinatorV2Mock_deploy',
];