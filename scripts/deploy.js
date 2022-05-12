/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  // deploy BaseDiamondCloneFacet
  const BaseDiamondCloneFacet = await ethers.getContractFactory(
    "BaseDiamondCloneFacet"
  );
  const baseDiamondCloneFacet = await BaseDiamondCloneFacet.deploy();
  await baseDiamondCloneFacet.deployed();

  const BaseNFTFacet = await ethers.getContractFactory("BaseNFTFacet");
  const baseNFTFacet = await BaseNFTFacet.deploy();
  await baseNFTFacet.deployed();

  // deploy the SAW!
  const DiamondSaw = await ethers.getContractFactory("DiamondSaw");
  const diamondSaw = await DiamondSaw.deploy();
  await diamondSaw.deployed();

  // add the BaseDiamond and BaseNFT facet pattern to the SAW
  const add = [
    {
      facetAddress: baseDiamondCloneFacet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(baseDiamondCloneFacet),
    },
    {
      facetAddress: baseNFTFacet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(baseNFTFacet),
    },
  ];

  await diamondSaw.addFacetPattern(add, ethers.constants.AddressZero, "0x");

  // deploy Diamond Clone
  const DiamondClone = await ethers.getContractFactory("DiamondClone");

  let functionCall = baseNFTFacet.interface.encodeFunctionData("init");

  const diamondClone = await DiamondClone.deploy(
    diamondSaw.address,
    [baseDiamondCloneFacet.address, baseNFTFacet.address],
    baseNFTFacet.address,
    functionCall
  );
  await diamondClone.deployed();

  return {
    diamondAddress: diamondClone.address,
    initCallData: functionCall,
    sawInstance: diamondSaw,
    baseNFTFacetImplementation: baseNFTFacet,
    baseDiamondImplementation: baseDiamondCloneFacet,
  };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

exports.deployDiamond = deployDiamond;
