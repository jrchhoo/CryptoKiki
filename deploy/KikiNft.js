module.exports = async (hre) => {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const { deployer, owner } = await getNamedAccounts();
    await deploy("KikiNft", {
        contract: "KikiNft",
        from: deployer,
        args: [owner, "https://ipfs.io/"],
        log: true,
    });
};

module.exports.tags = ["KikiNft"];
