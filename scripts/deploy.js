/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

const maxFeePerGas = 5000000000;
const maxPriorityFeePerGas = 3000000000;

async function deployDiamond() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  // deploy BaseDiamondCloneFacet
  const BaseDiamondCloneFacet = await ethers.getContractFactory(
    "BaseDiamondCloneFacet"
  );
  const baseDiamondCloneFacet = await BaseDiamondCloneFacet.deploy({
    maxFeePerGas,
    maxPriorityFeePerGas,
  });

  console.log(
    "Deploy diamond Clone Facet with txn hash",
    baseDiamondCloneFacet.deployTransaction.hash
  );

  await baseDiamondCloneFacet.deployed();

  const BaseNFTFacet = await ethers.getContractFactory("BaseNFTFacet");
  const baseNFTFacet = await BaseNFTFacet.deploy({
    maxFeePerGas,
    maxPriorityFeePerGas,
  });
  console.log(
    "Deploy NFT Facet with txn hash",
    baseNFTFacet.deployTransaction.hash
  );
  await baseNFTFacet.deployed();

  // deploy the SAW!
  const DiamondSaw = await ethers.getContractFactory("DiamondSaw");
  const diamondSaw = await DiamondSaw.deploy({
    maxFeePerGas,
    maxPriorityFeePerGas,
  });
  console.log(
    "Deploy Diamond Saw with txn hash",
    diamondSaw.deployTransaction.hash
  );
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

  const tx = await diamondSaw.addFacetPattern(
    add,
    ethers.constants.AddressZero,
    "0x",
    { maxFeePerGas, maxPriorityFeePerGas, gasLimit: 1500000 }
  );

  await tx.wait();

  console.log("Cutting saw with txn hash", tx.hash);

  // deploy Diamond Clone
  const DiamondClone = await ethers.getContractFactory("DiamondClone");

  let functionCall = baseNFTFacet.interface.encodeFunctionData("init");

  const diamondClone = await DiamondClone.deploy(
    diamondSaw.address,
    [baseDiamondCloneFacet.address, baseNFTFacet.address],
    baseNFTFacet.address,
    functionCall,
    { maxFeePerGas, maxPriorityFeePerGas }
  );

  console.log(
    "Deploy Diamond Saw with txn hash",
    diamondSaw.deployTransaction.hash
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
