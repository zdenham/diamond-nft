import '@nomiclabs/hardhat-waffle';

const { deployDiamond } = require('../../scripts/deployDiamondSaw.js');

import { BaseNFTFacet } from '../../typechain-types';

const { assert, expect } = require('chai');
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import { checkAdminFuncs } from '../../scripts/libraries/accessControl';

describe('AccessControlTest', async function () {
  let diamondAddress,
    accessControlFacet,
    nonOwnerAccessControlFacet,
    contractOwner,
    nonOwner: SignerWithAddress,
    accounts;

  beforeEach(async function () {
    const data = await deployDiamond();
    diamondAddress = data.diamondAddress;
    accessControlFacet = (await ethers.getContractAt(
      'BaseNFTFacet',
      diamondAddress
    )) as BaseNFTFacet;

    accounts = await ethers.getSigners();
    contractOwner = accounts[0];
    nonOwner = accounts[1];

    nonOwnerAccessControlFacet = accessControlFacet.connect(
      nonOwner
    ) as BaseNFTFacet;
  });

  it('should only allow the owner to add or remove operators', async () => {
    await expect(
      nonOwnerAccessControlFacet.grantOperator(nonOwner.address)
    ).to.be.revertedWith('Caller is not the owner');

    await accessControlFacet.grantOperator(nonOwner.address);

    await nonOwnerAccessControlFacet.devMint(nonOwner.address, 1);

    const ownerof = await accessControlFacet.ownerOf(0);
    expect(ownerof).to.equal(nonOwner.address);
  });

  it('should renounce both owners and operators on an ownership renounce', async () => {
    await accessControlFacet.grantOperator(nonOwner.address);

    await accessControlFacet.renounceOwnership();

    await expect(
      nonOwnerAccessControlFacet.devMint(nonOwner.address, 1)
    ).to.be.revertedWith('Admin functionality revoked');
  });

  it('should allow ownership transfer by the current owner', async () => {
    await accessControlFacet.transferOwnership(nonOwner.address);

    await nonOwnerAccessControlFacet.devMint(nonOwner.address, 1);

    const ownerof = await accessControlFacet.ownerOf(0);
    expect(ownerof).to.equal(nonOwner.address);
  });

  it('should not allow operators to access owner functionality', async () => {
    await accessControlFacet.grantOperator(nonOwner.address);

    await expect(
      nonOwnerAccessControlFacet.setTokenMeta('blah', 'blah', 0)
    ).to.be.revertedWith('Caller is not the owner');
  });

  it('should allow for revoking of operator', async () => {
    await accessControlFacet.grantOperator(nonOwner.address);

    await accessControlFacet.revokeOperator(nonOwner.address);

    await expect(
      nonOwnerAccessControlFacet.devMint(nonOwner.address, 1)
    ).to.be.revertedWith('AccessControl: account ');
  });

  it('should properly gate all admin functions', async () => {
    const accessControlCalls = [
      {
        signature: 'renounceOwnership()',
        args: [],
      },
      {
        signature: 'transferOwnership(address)',
        args: [ethers.constants.AddressZero],
      },
      {
        signature: 'grantOperator(address)',
        args: [ethers.constants.AddressZero],
      },
      {
        signature: 'revokeOperator(address)',
        args: [ethers.constants.AddressZero],
      },
    ];

    await checkAdminFuncs(accessControlFacet, nonOwner, accessControlCalls);
  });
});
