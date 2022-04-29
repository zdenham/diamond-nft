// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";

import { LibDiamond } from "./libraries/LibDiamond.sol";

import "hardhat/console.sol";

/**
 * DiamondSaw is meant to be used as a
 * Singleton to "cut" many minimal diamond clones
 * In a gas efficient manner for deployments.
 * 
 * This is accomplished by handling the storage intensive 
 * selector mappings in one contract, "the saw" instead of in each diamond.
 *
 * Adding a new facet to the saw enables new diamond "patterns"
 * 
 * This should be used if you
 * 
 * 1. Need cheap deployments of many similar cloned diamonds that
 * utilize the same pre-deployed facets
 * 
 * 2. Are okay with gas overhead on write txn to the diamonds
 * to communicate with the singleton (saw) to fetch selectors
 * 
 */
contract DiamondSaw {
  // TODO - VERY IMPORTANT
  // only ADD operations should be supported
  // and selectors should never be able to be overridden
  // otherwise diamond clones will not be guarunteed to be immutable
  // for now just do a normal library diamond cut
  function addFacetPattern(
    IDiamondCut.FacetCut[] memory _facetAdds,
    address _init,
    bytes memory _calldata
  ) public {
    LibDiamond.diamondCut(_facetAdds, _init, _calldata);
  }

  // if a facet has no selectors, it is not supported
  function isFacetSupported(address _facetAddress) external view {
    require(LibDiamond.diamondStorage().facetFunctionSelectors[_facetAddress].functionSelectors.length > 0, 'Facet not supported');
  }

  function facetAddressForSelector(bytes4 selector) external view returns (address) {
    return LibDiamond.diamondStorage().selectorToFacetAndPosition[selector].facetAddress;
  }
}