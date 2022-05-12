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

  it("should properly pass through the name, symbol, and max supply", async () => {
    await baseNFTFacetInstance.setTokenMeta("Blah", "Blah", 1);

    const name = await baseNFTFacetInstance.name();
    const symbol = await baseNFTFacetInstance.symbol();

    expect(name).to.equal("Blah");
    expect(symbol).to.equal("Blah");
  });

  it("should add erc721A functions", async () => {
    await baseNFTFacetInstance.devMint(contractOwner.address, 3);

    const nftOwner = await baseNFTFacetInstance.ownerOf(1);

    expect(nftOwner).to.equal(contractOwner.address);
  });

  it("should not allow reinitialization of BaseNFT", async () => {
    await expect(baseNFTFacetInstance.init()).to.be.revertedWith(
      "Already initted"
    );
  });

  it("Should reject public sale if the sale state is incorrect", async () => {
    expect(false).to.equal(true);
  });

  it("should fail to mint if max supply is reached", async () => {
    expect(false).to.equal(true);
  });

  it("should handle max supply appropriately with non zero start token", async () => {
    expect(false).to.equal(true);
  });

  it("should handle max supply appropriately with a zero start token", async () => {});

  it("should fail to set max supply to lower than current total supply", async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it("should reject public mints below the mint price", async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it("should appropriately set mint price and max supply", async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it("should support burning tokens", async () => {
    expect(false).to.equal(true);
  });
});
