module.exports = async (hre) => {
    const { deployments, getNamedAccounts } = hre;
    const { deploy, execute } = deployments;
    const { deployer, owner } = await getNamedAccounts();
    const result = await deploy("KikiNft", {
        contract: "KikiNft",
        from: deployer,
        args: [owner, "https://ipfs.io/"],
        log: true,
    });

    await execute(
        "Config",
        { from: owner, log: true },
        "setAddress",
        ethers.utils.id("RECEIVER"),
        result.address
    );
};

module.exports.tags = ["KikiNft"];
module.exports.dependencies = ["Config"];
