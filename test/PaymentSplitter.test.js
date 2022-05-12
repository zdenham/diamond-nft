const {
  getSelectors,
  FacetCutAction,
} = require("../scripts/libraries/diamond.js");
require("@nomiclabs/hardhat-waffle");

const { deployDiamond } = require("../scripts/deploy.js");

const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

const cutAbi = require("../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json");

describe("AccessControlTest", async function () {
  let diamondAddress,
    initCallData,
    sawInstance,
    baseNFTFacetImplementation,
    baseNFTFacetInstance,
    contractOwner,
    accounts;

  beforeEach(async function () {
    const data = await deployDiamond();
    diamondAddress = data.diamondAddress;
    initCallData = data.initCallData;
    sawInstance = data.sawInstance;
    baseNFTFacetImplementation = data.baseNFTFacetImplementation;
    baseNFTFacetInstance = await ethers.getContractAt(
      "BaseNFTFacet",
      diamondAddress
    );
    accounts = await ethers.getSigners();
    contractOwner = accounts[0];
  });
});
