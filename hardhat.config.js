require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.18",
  networks: {
    ganache:{
      url: "HTTP://127.0.0.1:7545",
      accounts: ["0x44ebc40400900aa60d9c00cefd03fc0a5254b33ce8ae2db055bd0ae6f2d58a08"],
      gas: 80000000
    }
  }
};
