/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require('hardhat')
const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  // deploy DiamondCutFacet
  // const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  // const diamondCutFacet = await DiamondCutFacet.deploy()
  // await diamondCutFacet.deployed()

  const ERC721AFacet = await ethers.getContractFactory('ERC721AFacet')
  const erc721AFacet = await ERC721AFacet.deploy();
  await erc721AFacet.deployed();

  // deploy the SAW!
  const DiamondSaw = await ethers.getContractFactory('DiamondSaw');
  const diamondSaw = await DiamondSaw.deploy();
  await diamondSaw.deployed();

  // add the ERC721A facet pattern to the SAW
  diamondSaw.addFacetPattern()

  // deploy Diamond Clone
  const DiamondClone = await ethers.getContractFactory('DiamondClone');
  const diamondClone = await DiamondClone.deploy(diamondSaw.address, [erc721AFacet.address]);
  await diamondClone.deployed();

  console.log('Diamond deployed:', diamondClone.address);

  return diamondClone.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond
