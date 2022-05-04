// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DiamondSaw.sol";

library LibDiamondClone {
    bytes32 constant DIAMOND_CLONE_STORAGE_POSITION = keccak256("diamond.standard.diamond.clone.storage");

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    struct DiamondCloneStorage {
        // address of the diamond saw contract
        address diamondSawAddress;
        // mapping to all the facets this diamond implements.
        mapping(address => bool) facetAddresses;
        // gas cache (TODO)
        mapping(bytes4 => address) selectorGasCache;
    }

    function getDiamondCloneStorage() internal pure returns (DiamondCloneStorage storage s) {
        bytes32 position = DIAMOND_CLONE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function initialCutWithDiamondSaw(
        address diamondSawAddress,
        address[] calldata facetAddresses,
        address _init, // base facet address
        bytes calldata _calldata // appropriate call data
    ) internal {
        LibDiamondClone.DiamondCloneStorage storage s = LibDiamondClone.getDiamondCloneStorage();

        require(diamondSawAddress != address(0), "Must set saw addy");
        require(s.diamondSawAddress == address(0), "Already inited");

        s.diamondSawAddress = diamondSawAddress;
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](facetAddresses.length);

        // emit the diamond cut event
        for (uint256 i; i < facetAddresses.length; i++) {
            address facetAddress = facetAddresses[i];
            bytes4[] memory selectors = DiamondSaw(diamondSawAddress).functionSelectorsForFacetAddress(facetAddress);

            require(selectors.length > 0, "Facet is not supported!!!");

            cuts[i].facetAddress = facetAddresses[i];
            cuts[i].functionSelectors = selectors;
            s.facetAddresses[facetAddress] = true;
        }

        emit DiamondCut(cuts, _init, _calldata);

        // call the init function
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up the error
                revert(string(error));
            } else {
                revert("LibDiamondClone: _init function reverted");
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

            require(selectors.length > 0, "Facet is not supported!!!");
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
                revert("LibDiamondClone: _init function reverted");
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
}
