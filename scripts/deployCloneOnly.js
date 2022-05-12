const { ethers } = require("hardhat");

const baseDiamondCloneFacetAddress =
  "0x43bb7820cf826a7a927518A30FF467Bf252001f8";
const baseNFTFacetAddress = "0x4D186de09e4D266D8c36E7364a24F0A7b0e9E4Cd";
const diamondSawAddress = "0x6a93A8766e96BcC7749682C37F12d4cAcc74fC2E";
const diamondCloneAddress = "0xFf2c1dab00Ea14E17514CA884b9bdae027BBEd83";

const maxFeePerGas = 5000000000;
const maxPriorityFeePerGas = 3000000000;

async function deployDiamondClone() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  const baseNFTFacet = await ethers.getContractAt(
    "BaseNFTFacet",
    baseNFTFacetAddress
  );
  const baseDiamondCloneFacet = await ethers.getContractAt(
    "BaseDiamondCloneFacet",
    baseDiamondCloneFacetAddress
  );

  // deploy Diamond Clone
  const DiamondClone = await ethers.getContractFactory("DiamondClone");

  let functionCall = baseNFTFacet.interface.encodeFunctionData("init");

  const diamondClone = await DiamondClone.deploy(
    diamondSawAddress,
    [baseDiamondCloneFacet.address, baseNFTFacet.address],
    baseNFTFacet.address,
    functionCall,
    { maxFeePerGas, maxPriorityFeePerGas }
  );

  console.log(
    "Deploy Diamond Clone with txn hash",
    diamondClone.deployTransaction.hash
  );

  await diamondClone.deployed();
}

if (require.main === module) {
  deployDiamondClone()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}
