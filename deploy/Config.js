module.exports = async (deployments, getNamedAccounts) => {
    const { deploy } = deployments;
    const { deployer, owner } = await getNamedAccounts();

    await deploy("Config", {
        contract: "Config",
        from: deployer,
        args: [owner],
        log: true
    });
};

module.exports.tags = ["Config"];
