require("hardhat-deploy");
require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    nftDeployer: {
      default: 0, 
    },
    oracleDeployer: {
      default: 1, 
    },
    erc20Deployer: {
      default: 2, 
    },
    auctionDeployer: {
      default: 3, 
    }
  }
};
