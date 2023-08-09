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
        "0xe876d00b59a7418144a59c4ce6563026b73b9146f8145884fa5fcc5ad4555597",
      ],
    },
  },
};
