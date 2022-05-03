// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DiamondSaw.sol";

// NOTE: this implementation is just
// a quick example of a single cut
//
// TODO: implement diamondCut, ownership & loupe
// functionality (that reads from the saw) and
// adjusts the local implementationFacet address map
// also need event emmissions to be fully
// compliant w/ the diamond standard

bytes32 constant DIAMOND_CLONE_STORAGE_POSITION = keccak256("diamond.standard.diamond.clone.storage");

library LibDiamondClone {
    // bytes32 constant DIAMOND_CLONE_STORAGE_POSITION = keccak256("diamond.standard.diamond.clone.storage");

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

    function diamondCut(address _facetAddress, bytes memory _calldata) internal {
        (bool success, bytes memory error) = _facetAddress.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up the error
                revert(string(error));
            } else {
                revert("LibDiamondCut: _init function reverted");
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

contract DiamondClone {
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    constructor(
        address diamondSawAddress,
        address[] memory facetAddresses,
        address _init, // base facet address
        bytes memory _calldata // appropriate call data
    ) {
        LibDiamondClone.getDiamondCloneStorage().diamondSawAddress = diamondSawAddress;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](facetAddresses.length);

        // emit the diamond cut event
        for (uint256 i; i < facetAddresses.length; i++) {
            bytes4[] memory selectors = DiamondSaw(diamondSawAddress).functionSelectorsForFacetAddress(facetAddresses[i]);
            cuts[i].facetAddress = facetAddresses[i];
            cuts[i].functionSelectors = selectors;
        }

        emit DiamondCut(cuts, _init, _calldata);

        // call the init function
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up the error
                revert(string(error));
            } else {
                revert("LibDiamondCut: _init function reverted");
            }
        }
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        // TODO - implement a "gas cache" that keeps track of
        // highly trafficked write selector on the diamond itself
        // referencing the selector gas cache will be cheaper than
        // calling externally
        address facet = LibDiamondClone._getFacetAddressForCall();

        // check if the facet address exists on the saw AND is included in our local cut
        require(facet != address(0) && LibDiamondClone.getDiamondCloneStorage().facetAddresses[facet], "Diamond: Function does not exist");

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
