const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets,
} = require("../scripts/libraries/diamond.js");
require("@nomiclabs/hardhat-waffle");

const deployTest1Facet = async () => {
  const Test1Facet = await ethers.getContractFactory("Test1Facet");
  const test1Facet = await Test1Facet.deploy();
  await test1Facet.deployed();
  return test1Facet;
};

const getDecodedEventsFromContract = async (contractInstance) => {
  const events = await contractInstance.queryFilter(
    { address: contractInstance.address },
    0,
    999
  );

  // roundabout way of testing events in constructor
  const iface = new ethers.utils.Interface(cutAbi.abi);

  const decodedEvents = events
    .map((event) => {
      try {
        const decodedArr = iface.parseLog(event);
        return { ...decodedArr };
      } catch (_) {
        // event defined on different facet ABI
        return null;
      }
    })
    .filter((e) => !!e);

  return decodedEvents;
};

const { deployDiamond } = require("../scripts/deploy.js");

const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

const cutAbi = require("../artifacts/contracts/facets/DiamondClone/DiamondCloneCutFacet.sol/DiamondCloneCutFacet.json");

describe("DiamondTest", async function () {
  let diamondAddress,
    initCallData,
    sawInstance,
    baseNFTFacet,
    baseNFTFacetInstance,
    contractOwner,
    accounts;

  before(async function () {
    const data = await deployDiamond();
    diamondAddress = data.diamondAddress;
    initCallData = data.initCallData;
    sawInstance = data.sawInstance;
    baseNFTFacet = data.baseNFTFacet;
    baseNFTFacetInstance = await ethers.getContractAt(
      "BaseNFTFacet",
      diamondAddress
    );
    accounts = await ethers.getSigners();
    contractOwner = accounts[0];
  });

  it("should properly pass through the name, symbol, and max supply from calldata", async () => {
    const name = await baseNFTFacetInstance.name();
    const symbol = await baseNFTFacetInstance.symbol();

    expect(name).to.equal("Blah");
    expect(symbol).to.equal("Blah");
  });

  it("should add erc721A functions", async () => {
    await baseNFTFacetInstance.devMint(contractOwner.address, 3);

    const nftOwner = await baseNFTFacetInstance.ownerOf(1);

    expect(nftOwner).to.equal(contractOwner.address);
  });

  it("should emit a cut event as expected initially, and facets should match the cut event", async () => {
    const decodedEvents = await getDecodedEventsFromContract(
      baseNFTFacetInstance
    );

    expect(decodedEvents.length).to.equal(1);

    const args = decodedEvents[0].args;
    const cut = args[0];
    const addAction = 0;

    expect(cut.length).to.equal(1);
    expect(cut[0].facetAddress).to.equal(baseNFTFacet.address);
    expect(cut[0].action).to.equal(addAction);
    expect(cut[0].functionSelectors).to.have.same.members(
      getSelectors(baseNFTFacetInstance)
    );
    expect(args[1]).to.equal(baseNFTFacet.address);
    expect(args[2]).to.equal(initCallData);
  });

  it("should emit a cut event after a secondary cut, and facets should be properly reflected", async () => {
    const test1facet = await deployTest1Facet();
    const selectors = getSelectors(test1facet);
    const newCut = {
      facetAddress: test1facet.address,
      action: FacetCutAction.Add,
      functionSelectors: selectors,
    };

    // add the pattern to the saw
    await sawInstance.addFacetPattern(
      [newCut],
      ethers.constants.AddressZero,
      "0x"
    );

    await baseNFTFacetInstance.diamondCut(
      [newCut],
      ethers.constants.AddressZero,
      "0x",
      { gasLimit: 800000 }
    );

    const decodedEvents = await getDecodedEventsFromContract(
      baseNFTFacetInstance
    );

    expect(decodedEvents.length).to.equal(2);
    const args = decodedEvents[1].args;
    const cut = args[0];
    const addAction = 0;
    expect(cut.length).to.equal(1);
    expect(cut[0].facetAddress).to.equal(test1facet.address);
    expect(cut[0].action).to.equal(addAction);
    expect(cut[0].functionSelectors).to.have.same.members(selectors);
    expect(args[1]).to.equal(ethers.constants.AddressZero);
    expect(args[2]).to.equal("0x");
  });

  it("should not allow reinitialization of BaseNFT", async () => {
    await expect(
      baseNFTFacetInstance.init("New Init", "NEWSYMBOL", 10000)
    ).to.be.revertedWith("Already initted");
  });

  it("Should not allow blank symbols", async () => {
    const DiamondClone = await ethers.getContractFactory("DiamondClone");
    let functionCall = baseNFTFacet.interface.encodeFunctionData("init", [
      "Blah",
      "",
      10000,
    ]);
    expect(
      await DiamondClone.deploy(
        sawInstance.address,
        [baseNFTFacet.address],
        baseNFTFacet.address,
        functionCall
      )
    ).to.be.revertedWith("Blank symbol");
  });

  it("Should reject non-additive cuts in the diamond saw", async () => {
    const test1facet = await deployTest1Facet();
    const selectors = getSelectors(test1facet);
    const newCut = {
      facetAddress: test1facet.address,
      action: FacetCutAction.Add,
      functionSelectors: selectors,
    };

    // add the pattern to the saw
    await sawInstance.addFacetPattern(
      [newCut],
      ethers.constants.AddressZero,
      "0x"
    );

    // now try to remove it
    await expect(
      sawInstance.addFacetPattern(
        [{ ...newCut, action: FacetCutAction.Remove }],
        ethers.constants.AddressZero,
        "0x"
      )
    ).to.be.revertedWith("Only add action supported in saw");
  });

  it("Should properly reflect the current diamond clone facets in loupe", async () => {
    // TODO -
  });

  it("Should properly reflect the current diamond clone facets in loupe after a cut", async () => {
    // TODO -
  });

  it("Should reject an improper length of selectors passed to a cut", async () => {
    const test1facet = await deployTest1Facet();
    const selectors = getSelectors(test1facet);
    const newCut = {
      facetAddress: test1facet.address,
      action: FacetCutAction.Add,
      functionSelectors: selectors,
    };

    // add the pattern to the saw
    await sawInstance.addFacetPattern(
      [newCut],
      ethers.constants.AddressZero,
      "0x"
    );

    await expect(
      baseNFTFacetInstance.diamondCut(
        [{ ...newCut, functionSelectors: functionSelectors.slice(0, 5) }],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 800000 }
      )
    ).to.be.revertedWith(
      "You can only modify all selectors at once with diamond saw"
    );
  });

  it("Should reject a cut with an address that the saw does not support", async () => {
    // TODO -
  });

  it("Should reject duplicate selector additions to the saw", async () => {
    // TODO -
  });

  it("Should return appropriate ERC-165 interfaces set in the saw", async () => {
    // TODO -
  });

  it("Should reject public sale if the sale state is incorrect", async () => {
    // TODO -
  });

  it("should return the appropriate facet for a selector in the saw", async () => {
    // TODO -
  });

  it("should reject call to an unsupported selector", async () => {
    // TODO -
  });

  it("should fail to mint if max supply is reached", async () => {
    // TODO -
  });

  it("should fail to set max supply to lower than current total supply", async () => {
    // TODO -
  });

  it("should reject public mints below the mint price", async () => {
    // TODO -
  });

  it("should properly reflect the current facets and selectors in the saw read function after a facet addition", async () => {});

  it("should reject a call in the clone to a removed facet selector", async () => {});

  it("should gate owner or admin gated functions properly", async () => {
    // list out all owner / admin functions and test them here
  });

  // TODO - IT SHOULD PASS ALL ERC721A tests from their repo!

  // TODO - Include all the tests from the hardhat-diamond-3 repo
});
