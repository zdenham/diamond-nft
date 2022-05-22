import '@nomiclabs/hardhat-waffle';
import { getSelectors, FacetCutAction } from '../../scripts/libraries/diamond';

import {
  PaymentSplitterFacet,
  BaseDiamondCloneFacet,
  DiamondCloneCutFacet,
} from '../../typechain-types';

const { deployDiamond } = require('../../scripts/deployDiamondSaw.js');

import { expect } from 'chai';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

import { constants } from '@openzeppelin/test-helpers';

const { ZERO_ADDRESS } = constants;

const Token = ethers.getContractFactory('ERC20Mock');

async function expectRevert(promise, revertString) {
  await expect(promise).to.be.revertedWith(revertString);
}

function ether(etherStr) {
  return ethers.utils.parseEther(etherStr);
}

async function expectEvent(emitter, promise, eventName, ...args) {
  expect(promise)
    .to.emit(emitter, eventName)
    .withArgs(...args);
}

describe('PaymentSplitterTest', async function () {
  let diamondAddress,
    paymentSplitterFacetImplementation,
    paymentSplitter: PaymentSplitterFacet,
    accounts,
    signers: SignerWithAddress[],
    owner,
    payee1,
    payee2,
    payee3,
    nonpayee1,
    payer1,
    ownerSigner,
    payee1Signer,
    payee2Signer,
    payee3Signer,
    nonpayee1Signer,
    payer1Signer,
    amount;

  beforeEach(async function () {
    const data = await deployDiamond();
    diamondAddress = data.diamondAddress;
    paymentSplitterFacetImplementation =
      data.paymentSplitterFacetImplementation;

    const diamondClone = (await ethers.getContractAt(
      'BaseDiamondCloneFacet',
      diamondAddress
    )) as BaseDiamondCloneFacet;

    // Add the payment splitter facet
    const add = [
      {
        facetAddress: paymentSplitterFacetImplementation.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(paymentSplitterFacetImplementation),
      },
    ];
    await diamondClone.diamondCut(add, ethers.constants.AddressZero, '0x');

    paymentSplitter = (await ethers.getContractAt(
      'PaymentSplitterFacet',
      diamondAddress
    )) as PaymentSplitterFacet;

    signers = await ethers.getSigners();
    accounts = signers.map((signer) => signer.address);
    [owner, payee1, payee2, payee3, nonpayee1, payer1] = accounts;
    [
      ownerSigner,
      payee1Signer,
      payee2Signer,
      payee3Signer,
      nonpayee1Signer,
      payer1Signer,
    ] = signers;

    amount = ether('1');
  });

  it('rejects an empty set of payees', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([], []),
      'PaymentSplitter: no payees'
    );
  });

  it('rejects more payees than shares', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([payee1, payee2, payee3], [20, 30]),
      'PaymentSplitter: payees and shares length mismatch'
    );
  });

  it('rejects more shares than payees', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([payee1, payee2], [20, 30, 40]),
      'PaymentSplitter: payees and shares length mismatch'
    );
  });

  it('rejects null payees', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([payee1, ZERO_ADDRESS], [20, 30]),
      'PaymentSplitter: account is the zero address'
    );
  });

  it('rejects zero-valued shares', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([payee1, payee2], [20, 0]),
      'PaymentSplitter: shares are 0'
    );
  });

  it('rejects repeated payees', async function () {
    await expectRevert(
      paymentSplitter.setPaymentSplits([payee1, payee1], [20, 30]),
      'PaymentSplitter: account already has shares'
    );
  });

  context('once payments are set', function () {
    beforeEach(async function () {
      this.payees = [payee1, payee2, payee3];
      this.shares = [20, 10, 70];

      await paymentSplitter.setPaymentSplits(this.payees, this.shares);
      this.token = await (
        await Token
      ).deploy('My Token', 'MT', owner, ether('1000'));
    });

    it('rejects a second attempt to set payments', async function () {
      await expectRevert(
        paymentSplitter.setPaymentSplits(this.payees, this.shares),
        'Initializable: contract is already initialized'
      );
    });

    it('has total shares', async function () {
      const totalShares = await paymentSplitter.totalShares();
      expect(totalShares).to.equal(100);
    });

    it('has payees', async function () {
      await Promise.all(
        this.payees.map(async (payee, index) => {
          const gotPayee = await paymentSplitter.payee(index);
          const gotReleased = await paymentSplitter.released(payee);
          expect(gotPayee).to.equal(payee);
          expect(gotReleased).to.equal(0);
        })
      );
    });

    describe('accepts payments', async function () {
      it('Ether', async function () {
        await signers[0].sendTransaction({
          to: paymentSplitter.address,
          value: amount,
        });

        expect(
          await ethers.provider.getBalance(paymentSplitter.address)
        ).to.equal(amount);
      });

      it('Token', async function () {
        await this.token.transfer(paymentSplitter.address, amount, {
          from: owner,
        });

        expect(await this.token.balanceOf(paymentSplitter.address)).to.equal(
          amount
        );
      });
    });

    describe('shares', async function () {
      it('stores shares if address is payee', async function () {
        expect(await paymentSplitter.shares(payee1)).to.not.equal(0);
      });

      it('does not store shares if address is not payee', async function () {
        expect(await paymentSplitter.shares(nonpayee1)).to.equal(0);
      });
    });

    describe('release', async function () {
      describe('Ether', async function () {
        it('reverts if no funds to claim', async function () {
          await expectRevert(
            paymentSplitter.release(payee1),
            'PaymentSplitter: account is not due payment'
          );
        });
        it('reverts if non-payee want to claim', async function () {
          await signers[5].sendTransaction({
            to: paymentSplitter.address,
            value: amount,
          });
          await expectRevert(
            paymentSplitter.release(nonpayee1),
            'PaymentSplitter: account has no shares'
          );
        });
      });

      describe('Token', async function () {
        it('reverts if no funds to claim', async function () {
          await expectRevert(
            paymentSplitter.releaseToken(this.token.address, payee1),
            'PaymentSplitter: account is not due payment'
          );
        });
        it('reverts if non-payee want to claim', async function () {
          await this.token.transfer(paymentSplitter.address, amount, {
            from: owner,
          });
          await expectRevert(
            paymentSplitter.releaseToken(this.token.address, nonpayee1),
            'PaymentSplitter: account has no shares'
          );
        });
      });
    });

    describe('distributes funds to payees', async function () {
      it('Ether', async function () {
        await signers[5].sendTransaction({
          to: paymentSplitter.address,
          value: amount,
        });

        // receive funds
        const initBalance = await ethers.provider.getBalance(
          paymentSplitter.address
        );
        expect(initBalance).to.equal(amount);

        // distribute to payees

        const originalPayee1Balance = await ethers.provider.getBalance(payee1);
        paymentSplitter.release(payee1Signer);
        const promise = paymentSplitter.release(payee1);
        await expectEvent(
          paymentSplitter,
          promise,
          'PaymentReleased',
          payee1,
          ether('0.20')
        );
        const afterPayee1Balance = await ethers.provider.getBalance(payee1);
        const profit1 = afterPayee1Balance.sub(originalPayee1Balance);
        expect(profit1).to.equal(ether('0.20'));

        const originalPayee2Balance = await ethers.provider.getBalance(payee2);
        const promise2 = paymentSplitter.release(payee2);

        expectEvent(
          paymentSplitter,
          promise2,
          'PaymentReleased',
          payee2,
          ether('0.1')
        );
        const afterPayee2Balance = await ethers.provider.getBalance(payee2);
        const profit2 = afterPayee2Balance.sub(originalPayee2Balance);
        expect(profit2).to.equal(ether('0.10'));

        const originalPayee3Balance = await ethers.provider.getBalance(payee3);
        const promise3 = paymentSplitter.release(payee3);
        expectEvent(
          paymentSplitter,
          promise3,
          'PaymentReleased',
          payee3,
          ether('0.7')
        );

        const afterPayee3Balance = await ethers.provider.getBalance(payee3);
        const profit3 = afterPayee3Balance.sub(originalPayee3Balance);
        expect(profit3).to.equal(ether('0.70'));

        // end balance should be zero
        expect(
          await ethers.provider.getBalance(paymentSplitter.address)
        ).to.be.equal('0');

        // check correct funds released accounting
        expect(await paymentSplitter.totalReleased()).to.equal(initBalance);
      });

      it('Token', async function () {
        expect(await this.token.balanceOf(payee1)).to.equal('0');
        expect(await this.token.balanceOf(payee2)).to.equal('0');
        expect(await this.token.balanceOf(payee3)).to.equal('0');

        await this.token.transfer(paymentSplitter.address, amount, {
          from: owner,
        });

        expectEvent(
          paymentSplitter,
          paymentSplitter.releaseToken(this.token.address, payee1),
          'ERC20PaymentReleased',
          this.token.address,
          payee1,
          ether('0.20')
        );

        await this.token.transfer(paymentSplitter.address, amount, {
          from: owner,
        });

        expectEvent(
          paymentSplitter,
          paymentSplitter.releaseToken(this.token.address, payee1),
          'ERC20PaymentReleased',
          this.token.address,
          payee1,
          ether('0.20')
        );

        expectEvent(
          await paymentSplitter.releaseToken(this.token.address, payee2),
          'ERC20PaymentReleased',
          this.token.address,
          payee2,
          ether('0.20')
        );

        expectEvent(
          await paymentSplitter.releaseToken(this.token.address, payee3),
          'ERC20PaymentReleased',
          this.token.address,
          payee3,
          ether('1.40')
        );

        expect(await this.token.balanceOf(payee1)).to.equal(ether('0.40'));
        expect(await this.token.balanceOf(payee2)).to.equal(ether('0.20'));
        expect(await this.token.balanceOf(payee3)).to.equal(ether('1.40'));
      });
    });
  });

  it('should properly gate admin functions', async () => {
    expect(false).to.equal(true);
  });
});
