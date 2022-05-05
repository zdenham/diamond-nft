/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')
const { ethers } = require('hardhat')

describe('DiamondTest', async function () {
  let diamondAddress, baseNFTFacetInstance, contractOwner, accounts

  before(async function () {
    diamondAddress = await deployDiamond();
    baseNFTFacetInstance = await ethers.getContractAt('BaseNFTFacet', diamondAddress);
    erc721AFacetInstance = await ethers.getContractAt('ERC721AFacet', diamondAddress);
    accounts = await ethers.getSigners()
    contractOwner = accounts[0]
  })

  it('should properly pass through the name, symbol, and max supply from calldata', async () => {
    const name = await erc721AFacetInstance.name();
    const symbol = await erc721AFacetInstance.symbol();

    expect(name).to.equal('Blah');
    expect(symbol).to.equal('Blah');
  });

  it('should add erc721A functions', async () => {
    // try minting!
    await baseNFTFacetInstance.devMint(contractOwner.address, 3);

    const nftOwner = await baseNFTFacetInstance.ownerOf(1);
    
    expect(nftOwner).to.equal(contractOwner.address);
  })

  it('should gate owner or admin gated functions properly', async () => {
    // list out all owner / admin functions and test them here
  });


  it('should emit a cut event as expected initially', async () => {
    // TODO - cut it
  });

  it('should emit a cut event after a secondary cut', async () => {
    // TODO - 
  });

  it('should not allow reinitialization of BaseNFT', async () => {
    // TODO -  
  });

  it('Should not allow blank symbols', async () => {
    // TODO - 
  });

  it('Should reject non-additive cuts in the diamond saw', async () => {
    // TODO - 
  });

  it('Should properly reflect the current diamond clone facets in loupe', async () => {
    // TODO - 
  });

  it('Should properly reflect the current diamond clone facets in loupe after a cut', async () => {
    // TODO - 
  });

  it('Should reflect the current diamond clone facets after', async () => {
    // TODO - 
  });

  it('Should reject an improper length of selectors passed to a cut', async () => {
    // TODO - 
  });

  it('Should reject a cut with an address that the saw does not support', async () => {
    // TODO - 
  });

  it('Should reject duplicate selector additions to the saw', async () => {
    // TODO - 
  });

  it('Should return appropriate ERC-165 interfaces set in the saw', async () => {
    // TODO - 
  });

  it('Should reject public sale if the sale state is incorrect', async () => {
    // TODO - 
  });

  it('should return the appropriate facet for a selector in the saw', async () => {
    // TODO - 
  });

  it('should reject call to an unsupported selector', async () => {
    // TODO - 
  });

  it('should fail to mint if max supply is reached', async () => {
    // TODO - 
  });

  it('should fail to set max supply to lower than current total supply', async () => {
    // TODO - 
  });

  it('should reject public mints below the mint price', async () => {
    // TODO - 
  });

  it('should properly reflect the current facets and selectors in the saw read function after a cut', async () => {

  });

  it('should reject a call to a removed facet selector', async () => {

  });

  // TODO - IT SHOULD PASS ALL ERC721A tests from their repo!


  // TODO - Include all the tests from the hardhat-diamond-3 repo
})
