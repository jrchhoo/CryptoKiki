module.exports = async (deployments, getNamedAccounts) => {
    const { deploy } = deployments;
    const { deployer, owner} = await getNamedAccounts();

    await deploy("Mintable", {
        contract: "Mintable",
        from: deployer,
        args: [owner],
        log: true
    });
};

module.exports.tags = ["Mintable"];
