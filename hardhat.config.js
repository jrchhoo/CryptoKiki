require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-truffle5");
require('hardhat-deploy');
require('solidity-coverage');

module.exports = {
    networks: {
        hardhat: {
            live: false,
            saveDeployments: false,
            tags: ["local"],
        },
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        admin: {
            default: 1,
        },
        owner: "admin",
    },
    solidity: {
        compilers: [
            {
                version: "0.8.4",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
};
