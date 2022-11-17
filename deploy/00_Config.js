module.exports = async (hre) => {
    const { ethers, deployments, getNamedAccounts } = hre;
    const { deploy, execute } = deployments;
    const { deployer, owner } = await getNamedAccounts();
    await deploy("Config", {
        contract: "Config",
        from: deployer,
        args: [owner],
        log: true,
    });
    await execute(
        "Config",
        { from: owner, log: true },
        "setAddress",
        ethers.utils.id("RECEIVER"),
        owner
    );
};

module.exports.tags = ["Config"];
