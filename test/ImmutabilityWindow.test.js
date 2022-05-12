const {
  getSelectors,
  FacetCutAction,
} = require("../scripts/libraries/diamond.js");
require("@nomiclabs/hardhat-waffle");

const { deployDiamond } = require("../scripts/deploy.js");

const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

const cutAbi = require("../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json");

describe("DiamondTest", async function () {
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

  it("Should reject a cut during an immutability window", async () => {
    expect(false).to.equal(true);
  });

  it("Should reject a saw upgrade during an immutability window", async () => {
    expect(false).to.equal(true);
  });

  it("Should reject an update to the immutability window during an immutability window", async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it("should allow updates after the immutability window is complete", async () => {
    // TODO -
    expect(false).to.equal(true);
  });
});
