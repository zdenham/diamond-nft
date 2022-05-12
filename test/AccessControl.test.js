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

  it("should gate owner or admin gated functions properly", async () => {
    // list out all owner / admin functions and test them here
    expect(false).to.equal(true);
  });

  it("should only allow the owner to add or remove admins", async () => {
    expect(false).to.equal(true);
  });

  it("should renounce both owners and admins on an ownership renounce", async () => {
    expect(false).to.equal(true);
  });

  it("should allow ownership transfer by the current owner", async () => {
    expect(false).to.equal(true);
  });

  it("should not allow admins to access owner functionality", async () => {
    expect(false).to.equal(true);
  });
});
