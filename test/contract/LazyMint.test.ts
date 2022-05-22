const {
  getSelectors,
  FacetCutAction,
} = require('../../scripts/libraries/diamond.js');
import '@nomiclabs/hardhat-waffle';

const { deployDiamond } = require('../../scripts/deployDiamondSaw.js');

const { assert, expect } = require('chai');
import { ethers } from 'hardhat';

const cutAbi = require('../../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json');

describe('LazyMint', async function () {
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
      'BaseNFTFacet',
      diamondAddress
    );
    accounts = await ethers.getSigners();
    contractOwner = accounts[0];
  });

  it('Should reject public sale if the sale state is incorrect', async () => {
    expect(false).to.equal(true);
  });

  it('should fail to mint if max supply is reached', async () => {
    expect(false).to.equal(true);
  });

  it('should handle max supply appropriately with non zero start token', async () => {
    expect(false).to.equal(true);
  });

  it('should handle max supply appropriately with a zero start token', async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it('should fail to set max supply to lower than current total supply', async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it('should reject public mints below the mint price', async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it('should appropriately set mint price and max supply', async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it('should support burning tokens', async () => {
    expect(false).to.equal(true);
  });

  it('should properly gate admin functions', async () => {
    expect(false).to.equal(true);
  });
});
