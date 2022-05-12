require("@nomiclabs/hardhat-waffle");
require("hardhat-contract-sizer");
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@typechain/hardhat");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const {
  TESTNET_CONTRACT_OWNER_PRIVATE_KEY,
  HARDHAT_CONTRACT_OWNER_PRIVATE_KEY,
  MAINNET_CONTRACT_OWNER_PRIVATE_KEY,
  MUMBAI_RPC_URL,
  POLYGON_RPC_URL,
  POLYGON_SCANNER_API_KEY,
  MAINNET_SCANNER_API_KEY,
  RINKEBY_RPC_URL,
  MAINNET_RPC_URL,
} = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    local: {
      url: "http://127.0.0.1:8545",
      accounts: [HARDHAT_CONTRACT_OWNER_PRIVATE_KEY],
    },
    mumbai: {
      url: MUMBAI_RPC_URL,
      accounts: [TESTNET_CONTRACT_OWNER_PRIVATE_KEY],
    },
    polygon: {
      url: POLYGON_RPC_URL,
      accounts: [MAINNET_CONTRACT_OWNER_PRIVATE_KEY],
    },
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: [TESTNET_CONTRACT_OWNER_PRIVATE_KEY],
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      accounts: [MAINNET_CONTRACT_OWNER_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      polygon: POLYGON_SCANNER_API_KEY,
      mainnet: MAINNET_SCANNER_API_KEY,
    },
  },
};
