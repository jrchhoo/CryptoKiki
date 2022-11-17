module.exports = async (hre) => {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, execute } = deployments;
    const config = await deployments.get("Config");
    const { deployer, owner } = await getNamedAccounts();
    const result = await deploy("Kiki", {
        contract: "Kiki",
        from: deployer,
        args: [config.address],
        log: true,
    });
    await execute(
        "Config",
        { from: owner, log: true },
        "setAddress",
        ethers.utils.id("KKT"),
        result.address
    );
};

module.exports.tags = ["Kiki"];
module.exports.dependencies = ["Config"];
