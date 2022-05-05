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
    accounts = await ethers.getSigners()
    contractOwner = accounts[0]
  })

  it('should properly pass through the name and symbol from calldata', async () => {
    const name = await baseNFTFacetInstance.name();
    const symbol = await baseNFTFacetInstance.symbol();

    expect(name).to.equal('Blah');
    expect(symbol).to.equal('Blah');
  });

  it('should add erc721A functions', async () => {
    // try minting!
    await baseNFTFacetInstance.devMint(contractOwner.address, 3);

    const nftOwner = await baseNFTFacetInstance.ownerOf(1);
    
    expect(nftOwner).to.equal(contractOwner.address);
  })

  it('should emit an initial DiamondCut event', async () => {
    // TODO!
  })

  it('should remove ')
})
