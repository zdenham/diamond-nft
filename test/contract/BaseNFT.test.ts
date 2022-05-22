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

  it('should properly pass through the name, symbol, and max supply', async () => {
    await baseNFTFacetInstance.setTokenMeta('Blah', 'Blah', 1);

    const name = await baseNFTFacetInstance.name();
    const symbol = await baseNFTFacetInstance.symbol();

    expect(name).to.equal('Blah');
    expect(symbol).to.equal('Blah');
  });

  it('should add erc721A functions', async () => {
    await baseNFTFacetInstance.devMint(contractOwner.address, 3);

    const nftOwner = await baseNFTFacetInstance.ownerOf(1);

    expect(nftOwner).to.equal(contractOwner.address);
  });

  it('should not allow reinitialization of BaseNFT', async () => {
    await expect(baseNFTFacetInstance.init()).to.be.revertedWith(
      'Already initted'
    );
  });

  it('should support burning tokens', async () => {
    expect(false).to.equal(true);
  });

  it('should not allow re-initialization once ownership is renounced', async () => {
    expect(false).to.equal(true);
  });

  it('should properly gate admin functions', async () => {
    expect(false).to.equal(true);
  });
});
