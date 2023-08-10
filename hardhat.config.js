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
        "0xc79d11d3f93e60ee4be88fc3e5119b8475c24af795ee9497492651f522204e25",
      ],
    },
  },
};
