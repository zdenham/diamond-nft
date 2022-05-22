const {
  getSelectors,
  FacetCutAction,
} = require('../../scripts/libraries/diamond.js');
import '@nomiclabs/hardhat-waffle';

const { deployDiamond } = require('../../scripts/deployDiamondSaw.js');

const { assert, expect } = require('chai');
import { ethers } from 'hardhat';

const cutAbi = require('../../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json');

describe('DiamondTest', async function () {
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

  it('Should reduce the gas cost if the gas cache is set', async () => {
    expect(false).to.equal(true);
  });

  it('Should appropriately purge the gas cache on removal of a facet', async () => {
    expect(false).to.equal(true);
  });

  it('should reject setting of gas cache if the selector is not supported by the saw', async () => {
    expect(false).to.equal(true);
  });

  it('should reject setting of gas cache if the selector is not a part of the clone', async () => {
    expect(false).to.equal(true);
  });

  it('should appropriately purge the gas cache on diamond saw upgrade', async () => {
    expect(false).to.equal(true);
  });

  it('should properly gate admin functions', async () => {
    expect(false).to.equal(true);
  });
});
