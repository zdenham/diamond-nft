import '@nomiclabs/hardhat-waffle';
import { ethers, network, waffle } from 'hardhat';
import type { Nifty } from '../../typechain-types';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import * as chai from 'chai';
import * as chaiAsPromised from 'chai-as-promised';

chai.use(chaiAsPromised);

const { expect } = chai;

const maxSupply = 10;
const allowListPrice = 200;
const auctionDuration = 1 * 24 * 60 * 60; // days
const auctionStartPrice = 1000;
const auctionEndPrice = 200;
const priceDropInterval = 15 * 60; // minutes
const royaltyNumerator = 1000; // out of 10000

const originalBalance = ethers.BigNumber.from('10000000000000000000000');

describe('TestNiftyContract', function () {
  let nifty: Nifty;
  let owner: SignerWithAddress;
  let user1: SignerWithAddress;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();

    // reset the network to prevent tests from affecting each other
    await network.provider.send('hardhat_reset');

    const Nifty = await ethers.getContractFactory('Nifty');

    nifty = (await Nifty.deploy(
      user1.address,
      maxSupply,
      allowListPrice,
      auctionDuration,
      auctionStartPrice,
      auctionEndPrice,
      priceDropInterval,
      royaltyNumerator
    )) as Nifty;
  });

  it('should fail to mint if the sale has not started', async function () {
    await expect(nifty.mint(1)).to.eventually.be.rejectedWith(
      'Nifty: sale is not currently live'
    );
  });

  it('should fail to mint if not on the allowlist', async function () {
    await nifty.setSaleLive(true);
    await expect(
      nifty.mint(1, { value: allowListPrice })
    ).to.eventually.be.rejectedWith(
      'Nifty: sender does not have enough allow list entries'
    );
  });

  it('should mint the first allowList entry, but fail to mint after the allowList entry is used', async function () {
    await nifty.setAllowListAddress(owner.address, 1);
    await nifty.setSaleLive(true);

    await nifty.mint(1, { value: allowListPrice });
    const ownerAddress = await nifty.ownerOf(1);
    expect(ownerAddress).to.equal(owner.address);

    await expect(
      nifty.mint(1, { value: allowListPrice })
    ).to.eventually.be.rejectedWith(
      'Nifty: sender does not have enough allow list entries'
    );
  });

  it('should fail to mint for insufficient funds on the allowList', async function () {
    await nifty.setSaleLive(true);
    await expect(
      nifty.mint(1, { value: allowListPrice - 1 })
    ).to.eventually.be.rejectedWith('Nifty: not enough funds sent');
  });

  it('should set appropriate price with respect to time and the auction', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();

    const originalPrice = await nifty.getAuctionPrice();
    expect(originalPrice).to.equal(auctionStartPrice);

    // increase time (16 minutes)
    await network.provider.send('evm_increaseTime', [60 * 16]);
    await network.provider.send('evm_mine');

    const priceDiff = Math.floor(
      (auctionStartPrice - auctionEndPrice) / (4 * 24)
    );

    const nextPrice = await nifty.getAuctionPrice();

    expect(nextPrice).to.equal(auctionStartPrice - priceDiff);
  });

  it('should remain at the end price after the auction is complete', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();

    const originalPrice = await nifty.getAuctionPrice();
    expect(originalPrice).to.equal(auctionStartPrice);

    // increase time (16 minutes)
    await network.provider.send('evm_increaseTime', [60 * 60 * 25]);
    await network.provider.send('evm_mine');

    const nextPrice = await nifty.getAuctionPrice();

    expect(nextPrice).to.equal(auctionEndPrice);
  });

  it('should fail to mint during auction with insufficient funds', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();

    await nifty.mint(1, { value: auctionStartPrice });

    const ownerOf = await nifty.ownerOf(1);

    expect(ownerOf).to.equal(owner.address);

    await expect(
      nifty.mint(1, { value: auctionStartPrice - 1 })
    ).to.be.eventually.rejectedWith('Nifty: not enough funds sent');
  });

  it('should update the baseURI appropriately', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();

    await nifty.mint(1, { value: auctionStartPrice });

    const ogURI = await nifty.tokenURI(1);

    expect(ogURI).to.equal('ipfs://1');

    await nifty.setBaseURI('ipfs://blah/');

    const newURI = await nifty.tokenURI(1);

    expect(newURI).to.equal('ipfs://blah/1');
  });

  it('should reject appropriate calls when made by a non owner account', async function () {
    const nonOwnerContract = nifty.connect(user1);

    await expect(
      nonOwnerContract.setSaleLive(true)
    ).to.be.eventually.rejectedWith('Ownable');

    await expect(nonOwnerContract.startAuction()).to.be.eventually.rejectedWith(
      'Ownable'
    );

    await expect(
      nonOwnerContract.setBaseURI('blah')
    ).to.be.eventually.rejectedWith('Ownable');

    await expect(nonOwnerContract.withdraw()).to.be.eventually.rejectedWith(
      'Ownable'
    );
  });

  it('should fail to mint after max supply is reached', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();
    for (let i = 0; i < maxSupply; i++) {
      await nifty.mint(1, { value: auctionStartPrice });
    }

    await expect(
      nifty.mint(1, { value: auctionStartPrice })
    ).to.eventually.be.rejectedWith('Nifty: no Niftys left');
  });

  it('should properly withdraw balance to external wallet', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();

    await nifty.mint(1, { value: auctionStartPrice });

    const ogBalance = await waffle.provider.getBalance(user1.address);

    expect(ogBalance).to.equal(originalBalance);

    await nifty.withdraw();

    const balance = await waffle.provider.getBalance(user1.address);

    expect(balance).to.equal(originalBalance.add(auctionStartPrice));
  });

  it('should support minting multiple NFTs via allowList', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 2);
    await nifty.mint(2, { value: allowListPrice * 2 });

    const numMinted = await nifty.totalMinted();

    expect(numMinted).to.equal(2);

    const ownerOf1 = await nifty.ownerOf(1);
    expect(ownerOf1).to.equal(owner.address);

    const ownerOf2 = await nifty.ownerOf(2);
    expect(ownerOf2).to.equal(owner.address);
  });

  it('should support minting multiple NFTs via auction', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();
    await nifty.mint(2, { value: auctionStartPrice * 2 });

    const ownerOf1 = await nifty.ownerOf(1);
    expect(ownerOf1).to.equal(owner.address);

    const ownerOf2 = await nifty.ownerOf(2);
    expect(ownerOf2).to.equal(owner.address);
  });

  it('should reject insufficient funds for a multi-mint', async function () {
    await nifty.setSaleLive(true);
    await nifty.startAuction();
    await expect(
      nifty.mint(2, { value: auctionStartPrice * 1.5 })
    ).to.be.rejectedWith('Nifty: not enough funds sent');
  });

  it('should reject attempting to mint too many trees via allowList', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 2);
    await expect(
      nifty.mint(3, { value: allowListPrice * 3 })
    ).to.eventually.be.rejectedWith(
      'Nifty: sender does not have enough allow list entries'
    );
  });

  it('should issue an event for the mint', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 1);
    await expect(nifty.mint(1, { value: allowListPrice * 1 }))
      .to.emit(nifty, 'Transfer')
      .withArgs('0x0000000000000000000000000000000000000000', owner.address, 1);
  });

  it('should have an appropriate royalty set for marketplaces', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 1);
    await nifty.mint(1, { value: allowListPrice * 1 });

    const [receiverAddress, royaltyValue] = await nifty.royaltyInfo(1, 100);

    expect(receiverAddress).to.equal(nifty.address);
    expect(royaltyValue).to.equal(ethers.BigNumber.from(10));
  });

  it('should return an appropriate map of owners', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 2);
    await nifty.mint(2, { value: allowListPrice * 2 });

    const owners = await nifty.allOwners();

    const expectedOwners = new Array(maxSupply + 1).fill(
      '0x0000000000000000000000000000000000000000'
    );

    expectedOwners[1] = owner.address;
    expectedOwners[2] = owner.address;

    expect(owners).to.eql(expectedOwners);
  });

  it('should enforce max mints for address', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 2);
    await nifty.setMaxMintPerAddress(1);

    await expect(
      nifty.mint(2, { value: allowListPrice * 2 })
    ).to.be.eventually.rejectedWith(
      'Nifty: max mints for this address already reached'
    );
  });

  it('the owner should be able to mint for free without the sale enabled', async function () {
    await nifty.devMint(2);

    const ownerOf1 = await nifty.ownerOf(1);
    expect(ownerOf1).to.equal(owner.address);

    const ownerOf2 = await nifty.ownerOf(2);
    expect(ownerOf2).to.equal(owner.address);
  });

  it('should respect the max allowlist number', async function () {
    await nifty.setSaleLive(true);
    await nifty.setAllowListAddress(owner.address, 2);
    await nifty.setAllowListSize(1);

    await expect(
      nifty.mint(2, { value: allowListPrice * 2 })
    ).to.be.eventually.rejectedWith('Nifty: max allow list was reached');
  });

  it('should allow for multiple people to be added to the whitelist simultaneously', async function () {
    await nifty.setMultipleAllowListAddresses(
      [owner.address, user1.address],
      2
    );

    const ownerNum = await nifty.numAllowListEntries(owner.address);
    const user1Num = await nifty.numAllowListEntries(user1.address);

    expect(ownerNum).to.equal(2);
    expect(user1Num).to.equal(2);
  });

  it('should respect a new max supply if it is set', async function () {
    await nifty.setMaxSupply(1);

    await nifty.devMint(1);
    await expect(nifty.devMint(1)).to.eventually.be.rejectedWith(
      'Nifty: no Niftys left'
    );
  });

  it('should allow the owner to set allowlist and auction prices', async function () {
    await nifty.setAuctionStartPrice(220);
    await nifty.setAuctionEndPrice(50);
    await nifty.setAllowListPrice(75);

    const startPrice = await nifty.dutchAuctionStartPrice();
    const endPrice = await nifty.dutchAuctionEndPrice();
    const allowListPrice = await nifty.allowListPrice();

    expect(startPrice).to.equal(220);
    expect(endPrice).to.equal(50);
    expect(allowListPrice).to.equal(75);
  });
});
