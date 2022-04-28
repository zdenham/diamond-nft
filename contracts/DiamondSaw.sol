// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";

import { LibDiamond } from "./libraries/LibDiamond.sol";

/**
 * DiamondSaw is meant to be used as a
 * Singleton to "cut" many minimal diamond clones
 * In a gas efficient manner for deployments.
 * 
 * This is accomplished by handling the storage intensive 
 * selector mappings in one contract, "the saw" instead of in each diamond.
 * 
 * This should be used if you
 * 
 * 1. Need cheap deployments of many similar cloned diamonds that
 * utilize the same pre-deployed facets
 * 
 * 2. Are okay with gas overhead on ANY write txn to the diamonds
 * to communicate with the singleton (saw) to fetch selectors
 */
contract DiamondSaw is Ownable {
  constructor(){}

  function addFacetForCloning(address _newFacetAddress) public onlyOwner {
    // Add the diamondCut external function from the diamondCutFacet
    IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
    bytes4[] memory functionSelectors = new bytes4[](1);
    functionSelectors[0] = IDiamondCut.diamondCut.selector;
    cut[0] = IDiamondCut.FacetCut({
        facetAddress: _newFacetAddress, 
        action: IDiamondCut.FacetCutAction.Add, 
        functionSelectors: functionSelectors
    });
    LibDiamond.diamondCut(cut, address(0), "");   
  }

  // if a facet has no selectors, it is not supported
  function isFacetSupported(address _facetAddress) external view returns (bool) {
    return LibDiamond.diamondStorage().facetFunctionSelectors[_facetAddress].functionSelectors.length > 0;
  }
}