const {
  getSelectors,
  FacetCutAction,
} = require('../../scripts/libraries/diamond.js');
import '@nomiclabs/hardhat-waffle';

const {
  deployDiamond,
  getDecodedEventsFromContract,
  deployTest1Facet,
} = require('../../scripts/deployDiamondSaw.js');

const { assert, expect } = require('chai');
import { ethers } from 'hardhat';
import { checkAdminFuncs } from '../../scripts/libraries/accessControl';
import { BaseDiamondCloneFacet } from '../../typechain-types';

const cutAbi = require('../../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json');

describe('DiamondTest', async function () {
  let diamondAddress,
    initCallData,
    sawInstance,
    baseNFTFacetImplementation,
    baseNFTFacetInstance,
    contractOwner,
    accounts,
    diamondCloneFacet: BaseDiamondCloneFacet;

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

    diamondCloneFacet = (await ethers.getContractAt(
      'BaseDiamondCloneFacet',
      diamondAddress
    )) as BaseDiamondCloneFacet;
  });

  it('Should properly reflect the current diamond clone facets in loupe', async () => {
    const addresses = await diamondCloneFacet.facetAddresses();
    console.log('THE ADDRESSES!', addresses);
    expect(false).to.equal(true);
  });

  // it('should emit a cut event as expected initially, and facets should match the cut event', async () => {
  //   const decodedEvents = await getDecodedEventsFromContract(
  //     baseNFTFacetInstance
  //   );

  //   expect(decodedEvents.length).to.equal(1);

  //   const args = decodedEvents[0].args;
  //   const cut = args[0];
  //   const addAction = 0;

  //   expect(cut.length).to.equal(1);
  //   expect(cut[0].facetAddress).to.equal(baseNFTFacetImplementation.address);
  //   expect(cut[0].action).to.equal(addAction);
  //   expect(cut[0].functionSelectors).to.have.same.members(
  //     getSelectors(baseNFTFacetInstance)
  //   );
  //   expect(args[1]).to.equal(baseNFTFacetImplementation.address);
  //   expect(args[2]).to.equal(initCallData);
  // });

  // it('should emit a cut event after a secondary cut, and facets should be properly reflected', async () => {
  //   const test1facet = await deployTest1Facet();
  //   const selectors = getSelectors(test1facet);
  //   const newCut = {
  //     facetAddress: test1facet.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: selectors,
  //   };

  //   const facets = await sawInstance.allFacetAddresses();

  //   // add the pattern to the saw
  //   await sawInstance.addFacetPattern(
  //     [newCut],
  //     ethers.constants.AddressZero,
  //     '0x'
  //   );

  //   await baseNFTFacetInstance.diamondCut(
  //     [newCut],
  //     ethers.constants.AddressZero,
  //     '0x',
  //     { gasLimit: 800000 }
  //   );

  //   const decodedEvents = await getDecodedEventsFromContract(
  //     baseNFTFacetInstance
  //   );

  //   expect(decodedEvents.length).to.equal(2);
  //   const args = decodedEvents[1].args;
  //   const cut = args[0];
  //   const addAction = 0;
  //   expect(cut.length).to.equal(1);
  //   expect(cut[0].facetAddress).to.equal(test1facet.address);
  //   expect(cut[0].action).to.equal(addAction);
  //   expect(cut[0].functionSelectors).to.have.same.members(selectors);
  //   expect(args[1]).to.equal(ethers.constants.AddressZero);
  //   expect(args[2]).to.equal('0x');
  // });

  // it('Should reject non-additive cuts in the diamond saw', async () => {
  //   const test1facet = await deployTest1Facet();
  //   const selectors = getSelectors(test1facet);

  //   const newCut = {
  //     facetAddress: test1facet.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: selectors,
  //   };

  //   // add the pattern to the saw
  //   await sawInstance.addFacetPattern(
  //     [newCut],
  //     ethers.constants.AddressZero,
  //     '0x'
  //   );

  //   // now try to remove it
  //   await expect(
  //     sawInstance.addFacetPattern(
  //       [{ ...newCut, action: FacetCutAction.Remove }],
  //       ethers.constants.AddressZero,
  //       '0x'
  //     )
  //   ).to.be.revertedWith('Only add action supported in saw');
  // });

  // it('Should reject an improper length of selectors passed to a cut', async () => {
  //   const test1facet = await deployTest1Facet();
  //   const selectors = getSelectors(test1facet);
  //   const newCut = {
  //     facetAddress: test1facet.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: selectors,
  //   };

  //   // add the pattern to the saw
  //   await sawInstance.addFacetPattern(
  //     [newCut],
  //     ethers.constants.AddressZero,
  //     '0x'
  //   );

  //   await expect(
  //     baseNFTFacetInstance.diamondCut(
  //       [{ ...newCut, functionSelectors: selectors.slice(0, 5) }],
  //       ethers.constants.AddressZero,
  //       '0x',
  //       { gasLimit: 800000 }
  //     )
  //   ).to.be.revertedWith(
  //     'You can only modify all selectors at once with diamond saw'
  //   );
  // });

  // it('Should reject a cut with a facet address that the saw does not support', async () => {
  //   const test1facet = await deployTest1Facet();
  //   const selectors = getSelectors(test1facet);
  //   const newCut = {
  //     facetAddress: test1facet.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: selectors,
  //   };

  //   await expect(
  //     baseNFTFacetInstance.diamondCut(
  //       [newCut],
  //       ethers.constants.AddressZero,
  //       '0x',
  //       { gasLimit: 800000 }
  //     )
  //   ).to.be.revertedWith('Facet is not supported by the saw');
  // });

  // it('Should reject duplicate selector additions to the saw', async () => {
  //   const selectors = getSelectors(baseNFTFacetImplementation);
  //   const newCut = {
  //     facetAddress: sawInstance.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: selectors,
  //   };

  //   await expect(
  //     sawInstance.addFacetPattern([newCut], ethers.constants.AddressZero, '0x')
  //   ).to.be.revertedWith('Cannot add function that already exists');
  // });

  // it('Should reject duplicate facet address additions to the saw', async () => {
  //   const newCut = {
  //     facetAddress: baseNFTFacetImplementation.address,
  //     action: FacetCutAction.Add,
  //     functionSelectors: ['0x12345678'],
  //   };

  //   await expect(
  //     sawInstance.addFacetPattern([newCut], ethers.constants.AddressZero, '0x')
  //   ).to.be.revertedWith('Facet already exists in saw');
  // });

  // it('Should return appropriate ERC-165 interfaces set in the saw', async () => {
  //   const erc165Interface = '0x12345678';

  //   const supported1 = await baseNFTFacetInstance.supportsInterface(
  //     erc165Interface
  //   );
  //   expect(supported1).to.equal(false);

  //   await sawInstance.setFacetForInterface(
  //     erc165Interface,
  //     baseNFTFacetImplementation.address
  //   );

  //   const supported2 = await baseNFTFacetInstance.supportsInterface(
  //     erc165Interface
  //   );
  //   expect(supported2).to.equal(true);
  // });

  // it('should support removing an ERC-165 interface from a given facet', async () => {
  //   // TODO -
  //   expect(false).to.equal(true);
  // });

  // it('Should fail to set the ERC-165 interface if the facet is not supported in the saw', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('should return the appropriate facet for a selector in the saw', async () => {
  //   // TODO -
  //   expect(false).to.equal(true);
  // });

  // it('should reject call to an unsupported selector', async () => {
  //   // TODO -
  //   expect(false).to.equal(true);
  // });

  // it('should properly reflect the current facets and selectors in the saw read function after a facet addition', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('should reject a call in the clone to a removed facet selector', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('Should properly reflect the current diamond clone facets in loupe after a cut', async () => {
  //   // TODO -
  //   expect(false).to.equal(true);
  // });

  // it('Should emit an appropriate diamond cut event when the diamond saw is upgraded', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('Should reject an upgrade if the upgrade saw is not set in the diamond saw', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('Should allow for the same selectors in the new saw', async () => {
  //   // TODO -
  //   expect(false).to.equal(true);
  // });

  // it('Should appropriately call the init function with an upgraded saw', async () => {
  //   expect(false).to.equal(true);
  // });

  // it('should properly gate all admin functions', async () => {
  //   const diamondFacetCalls = [
  //     {
  //       signature: 'diamondCut((address,uint8,bytes4[])[],address,bytes)',
  //       args: [[], ethers.constants.AddressZero, '0x'],
  //     },
  //     {
  //       signature: 'setGasCacheForSelector(bytes4)',
  //       args: ['0x00000000'],
  //       operator: true,
  //     },
  //     {
  //       signature: 'setImmutableUntilBlock(uint256)',
  //       args: [0],
  //     },
  //     {
  //       signature: 'upgradeDiamondSaw(address[],address[],address,bytes)',
  //       args: [[], [], ethers.constants.AddressZero, '0x'],
  //     },
  //   ];

  //   const diamondContract = await ethers.getContractAt(
  //     'BaseDiamondCloneFacet',
  //     diamondAddress
  //   );

  //   await checkAdminFuncs(diamondContract, accounts[1], diamondFacetCalls);
  // });
});
