const {
  getSelectors,
  FacetCutAction,
} = require('../../scripts/libraries/diamond.js');
import '@nomiclabs/hardhat-waffle';

const { deployDiamond } = require('../../scripts/deployDiamondSaw.js');

const { assert, expect } = require('chai');
import { ethers } from 'hardhat';

const cutAbi = require('../../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json');

describe('AccessControlTest', async function () {
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

  it('should set the base uri appripriately', async () => {
    // TODO -
    expect(false).to.equal(true);
  });

  it('should support setting a specific token uri which override the base uri', async () => {
    expect(false).to.equal(true);
  });

  it('should appropriately remove the token URI if the token is burned', async () => {
    // not sure if we need this one tbh
    expect(false).to.equal(true);
  });

  it('should properly gate admin functions', async () => {
    expect(false).to.equal(true);
  });
});
