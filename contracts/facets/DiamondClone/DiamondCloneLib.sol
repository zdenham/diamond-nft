// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../DiamondSaw.sol";
import {IDiamondLoupe} from "./IDiamondLoupe.sol";

library DiamondCloneLib {
    bytes32 constant DIAMOND_CLONE_STORAGE_POSITION = keccak256("diamond.standard.diamond.clone.storage");

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    struct DiamondCloneStorage {
        // address of the diamond saw contract
        address diamondSawAddress;
        // mapping to all the facets this diamond implements.
        mapping(address => bool) facetAddresses;
        // optional gas cache for highly trafficked write selectors
        mapping(bytes4 => address) optionalSelectorGasCache;
        // optional facet gas cache to make loupe cheaper
        address[] optionalFacetAddressGasCache;
    }

    function getDiamondCloneStorage() internal pure returns (DiamondCloneStorage storage s) {
        bytes32 position = DIAMOND_CLONE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function initialCutWithDiamondSaw(
        address diamondSawAddress,
        address[] calldata _facetAddresses,
        address _init, // base facet address
        bytes calldata _calldata // appropriate call data
    ) internal {
        DiamondCloneLib.DiamondCloneStorage storage s = DiamondCloneLib.getDiamondCloneStorage();

        require(diamondSawAddress != address(0), "Must set saw addy");
        require(s.diamondSawAddress == address(0), "Already inited");

        s.diamondSawAddress = diamondSawAddress;
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](_facetAddresses.length);

        // emit the diamond cut event
        for (uint256 i; i < _facetAddresses.length; i++) {
            address facetAddress = _facetAddresses[i];
            bytes4[] memory selectors = DiamondSaw(diamondSawAddress).functionSelectorsForFacetAddress(facetAddress);
            require(selectors.length > 0, "Facet is not supported by the saw");
            cuts[i].facetAddress = _facetAddresses[i];
            cuts[i].functionSelectors = selectors;
            s.facetAddresses[facetAddress] = true;
        }

        emit DiamondCut(cuts, _init, _calldata);

        // call the init function
        (bool success, bytes memory err) = _init.delegatecall(_calldata);

        if (!success) {
            if (err.length > 0) {
                // bubble up the error
                revert(string(err));
            } else {
                revert("DiamondCloneLib: _init function reverted");
            }
        }
    }

    function cutWithDiamondSaw(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes calldata _calldata
    ) internal {
        DiamondCloneStorage storage s = getDiamondCloneStorage();

        // emit the diamond cut event
        for (uint256 i; i < _diamondCut.length; i++) {
            IDiamondCut.FacetCut memory cut = _diamondCut[i];
            bytes4[] memory selectors = DiamondSaw(s.diamondSawAddress).functionSelectorsForFacetAddress(cut.facetAddress);

            require(selectors.length > 0, "Facet is not supported by the saw");
            require(selectors.length == cut.functionSelectors.length, "You can only modify all selectors at once with diamond saw");

            // NOTE we override the passed selectors after validating the length matches
            // With diamond saw we can only add / remove all selectors for a given facet
            cut.functionSelectors = selectors;

            // if the address is already in the facet map
            // remove it and remove all the selectors
            // otherwise add the selectors
            if (s.facetAddresses[cut.facetAddress]) {
                require(cut.action == IDiamondCut.FacetCutAction.Remove, "Can only remove existing facet selectors");
                s.facetAddresses[cut.facetAddress] = false;
            } else {
                require(cut.action == IDiamondCut.FacetCutAction.Add, "Can only add non-existing facet selectors");
                s.facetAddresses[cut.facetAddress] = true;
            }
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        // call the init function
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up the error
                revert(string(error));
            } else {
                revert("DiamondCloneLib: _init function reverted");
            }
        }
    }

    // calls externally to the saw to find the appropriate facet to delegate to
    function _getFacetAddressForCall() internal returns (address addr) {
        (bool success, bytes memory res) = getDiamondCloneStorage().diamondSawAddress.call(
            abi.encodeWithSignature("facetAddressForSelector(bytes4)", msg.sig)
        );
        require(success, "Failed to fetch facet address for call");

        assembly {
            addr := mload(add(res, 32))
        }
    }

    /**
     * LOUPE FUNCTIONALITY BELOW
     */

    function facets() internal view returns (IDiamondLoupe.Facet[] memory facets_) {
        DiamondCloneLib.DiamondCloneStorage storage ds = DiamondCloneLib.getDiamondCloneStorage();
        IDiamondLoupe.Facet[] memory allSawFacets = DiamondSaw(ds.diamondSawAddress).allFacetsWithSelectors();

        uint256 copyIndex = 0;

        // start the array with full lengh of saw facets
        facets_ = new IDiamondLoupe.Facet[](allSawFacets.length);

        for (uint256 i; i < allSawFacets.length; i++) {
            if (ds.facetAddresses[allSawFacets[i].facetAddress]) {
                facets_[copyIndex] = allSawFacets[i];
            } else {
                // reduce the length of the facets_ array
                assembly {
                    mstore(facets_, sub(mload(facets_), 1))
                }
            }
            copyIndex++;
        }
    }

    function facetAddresses() internal view returns (address[] memory facetAddresses_) {
        DiamondCloneLib.DiamondCloneStorage storage ds = DiamondCloneLib.getDiamondCloneStorage();

        address[] memory allSawFacetAddresses = DiamondSaw(ds.diamondSawAddress).allFacetAddresses();
        facetAddresses_ = new address[](allSawFacetAddresses.length);

        uint256 copyIndex = 0;

        for (uint256 i; i < allSawFacetAddresses.length; i++) {
            if (ds.facetAddresses[allSawFacetAddresses[i]]) {
                facetAddresses_[copyIndex] = allSawFacetAddresses[i];
            } else {
                assembly {
                    mstore(facetAddresses_, sub(mload(facetAddresses_), 1))
                }
            }

            copyIndex++;
        }
    }
}
