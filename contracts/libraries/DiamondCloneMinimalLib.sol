// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// minimal inline subset of the full DiamondCloneLib to reduce deployment gas costs
library DiamondCloneMinimalLib {
    bytes32 constant DIAMOND_CLONE_STORAGE_POSITION = keccak256("diamond.standard.diamond.clone.storage");

    struct DiamondCloneStorage {
        // address of the diamond saw contract
        address diamondSawAddress;
        // mapping to all the facets this diamond implements.
        mapping(address => bool) facetAddresses;
        // gas cache (TODO)
        mapping(bytes4 => address) selectorGasCache;
    }

    function diamondCloneStorage() internal pure returns (DiamondCloneStorage storage s) {
        bytes32 position = DIAMOND_CLONE_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    // calls externally to the saw to find the appropriate facet to delegate to
    function _getFacetAddressForCall() internal returns (address addr) {
        (bool success, bytes memory res) = diamondCloneStorage().diamondSawAddress.call(
            abi.encodeWithSignature("facetAddressForSelector(bytes4)", msg.sig)
        );
        require(success, "Failed to fetch facet address for call");

        assembly {
            addr := mload(add(res, 32))
        }
    }
}
