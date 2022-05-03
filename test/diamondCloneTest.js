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
  let diamondAddress

  before(async function () {
    diamondAddress = await deployDiamond()
  })

  it('should add erc721A functions', async () => {
    const erc721Instance = await ethers.getContractAt('ERC721AFacet', diamondAddress);

    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]

    // try minting!
    await erc721Instance.devMint(contractOwner.address, 3);

    const nftOwner = await erc721Instance.ownerOf(1);
    
    expect(nftOwner).to.equal(contractOwner.address);
  })
})
