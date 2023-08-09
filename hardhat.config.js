require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    ganache: {
      url: "HTTP://127.0.0.1:8545",

      accounts: [
        "0x0f8a816a6e3e2de452d6a968e54968af24c30ab77494aa44d0d45de3605241e7",
      ],
    },
  },
};
