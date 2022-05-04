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

    function cutWithDiamondSaw(
        address diamondSawAddress,
        address[] memory facetAddresses,
        address _init, // base facet address
        bytes memory _calldata // appropriate call data
    ) internal {
        LibDiamondClone.DiamondCloneStorage storage s = LibDiamondClone.getDiamondCloneStorage();
        s.diamondSawAddress = diamondSawAddress;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](facetAddresses.length);

        // emit the diamond cut event
        for (uint256 i; i < facetAddresses.length; i++) {
            address facetAddress = facetAddresses[i];
            bytes4[] memory selectors = DiamondSaw(diamondSawAddress).functionSelectorsForFacetAddress(facetAddress);

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
