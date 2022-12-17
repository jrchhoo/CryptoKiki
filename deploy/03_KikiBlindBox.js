const KEY_HASH = '0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc';

module.exports = async (hre) => {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, execute } = deployments;
    const config = await deployments.get("Config");
    const kiki = await deployments.get("Kiki");
    const VRFCoordinatorV2Mock = await deployments.get("VRFCoordinatorV2Mock");
    const { deployer, owner } = await getNamedAccounts();

    const result = await deploy("KikiBlindBox", {
        contract: "KikiBlindBox",
        from: deployer,
        args: [kiki.address, config.address, VRFCoordinatorV2Mock.address, KEY_HASH, 1, 'https://'],
        log: true,
    });
    // await execute(
    //     "Config",
    //     { from: owner, log: true },
    //     "setAddress",
    //     ethers.utils.id("KKT"),
    //     result.address
    // );
};

module.exports.tags = ["KikiBlindBox"];
module.exports.dependencies = ["Config", "Kiki", "VRFCoordinatorV2Mock_deploy"];
