module.exports = async (deployments, getNamedAccounts) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    await deploy("Config", {
        contract: "Config",
        from: deployer,
        args: [],
        log: true
    });
};

module.exports.tags = ["Config"];
