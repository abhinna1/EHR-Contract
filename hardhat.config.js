require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.18",
  networks: {
    ganache:{
      url: process.env.RPC_SERVER,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
