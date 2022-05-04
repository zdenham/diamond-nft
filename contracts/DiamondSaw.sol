// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "./interfaces/IDiamondLoupe.sol";

import {LibDiamondSaw} from "./libraries/LibDiamondSaw.sol";

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
    function addFacetPattern(
        IDiamondCut.FacetCut[] calldata _facetAdds,
        address _init,
        bytes calldata _calldata
    ) public {
        LibDiamondSaw.diamondCutAddOnly(_facetAdds, _init, _calldata);
    }

    // if a facet has no selectors, it is not supported
    function checkFacetSupported(address _facetAddress) external view {
        LibDiamondSaw.checkFacetSupported(_facetAddress);
    }

    function facetAddressForSelector(bytes4 selector) external view returns (address) {
        return LibDiamondSaw.diamondSawStorage().selectorToFacetAndPosition[selector].facetAddress;
    }

    function functionSelectorsForFacetAddress(address facetAddress) external view returns (bytes4[] memory) {
        return LibDiamondSaw.diamondSawStorage().facetFunctionSelectors[facetAddress].functionSelectors;
    }

    function allFacetAddresses() external view returns (address[] memory) {
        return LibDiamondSaw.diamondSawStorage().facetAddresses;
    }

    function allFacetsWithSelectors() external view returns (IDiamondLoupe.Facet[] memory _facetsWithSelectors) {
        LibDiamondSaw.DiamondSawStorage storage ds = LibDiamondSaw.diamondSawStorage();

        uint256 numFacets = ds.facetAddresses.length;
        _facetsWithSelectors = new IDiamondLoupe.Facet[](numFacets);
        for (uint256 i; i < numFacets; i++) {
            address facetAddress_ = ds.facetAddresses[i];
            _facetsWithSelectors[i].facetAddress = facetAddress_;
            _facetsWithSelectors[i].functionSelectors = ds.facetFunctionSelectors[facetAddress_].functionSelectors;
        }
    }

    function facetAddressForInterface(bytes4 _interface) external view returns (address) {
        LibDiamondSaw.DiamondSawStorage storage ds = LibDiamondSaw.diamondSawStorage();
        return ds.interfaceToFacet[_interface];
    }
}
