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
  let diamondAddress, erc721Instance, contractOwner, accounts

  before(async function () {
    diamondAddress = await deployDiamond();
    erc721Instance = await ethers.getContractAt('ERC721AFacet', diamondAddress);
    accounts = await ethers.getSigners()
    contractOwner = accounts[0]
  })

  it('should properly pass through the name and symbol from calldata', async () => {
    const name = await erc721Instance.name();
    const symbol = await erc721Instance.symbol();

    expect(name).to.equal('Blah');
    expect(symbol).to.equal('Blah');
  });

  it('should add erc721A functions', async () => {
    // try minting!
    await erc721Instance.devMint(contractOwner.address, 3);

    const nftOwner = await erc721Instance.ownerOf(1);
    
    expect(nftOwner).to.equal(contractOwner.address);
  })

  it('should emit an initial DiamondCut event', async () => {
    // TODO!
  })

  it('should remove ')
})
