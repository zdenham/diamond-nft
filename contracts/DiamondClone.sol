// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./facets/AppStorage.sol";

// NOTE: this implementation is just
// a quick example of a single cut
//
// TODO: implement diamondCut, ownership & loupe
// functionality (that reads from the saw) and
// adjusts the local implementationFacet address map
// also need event emmissions to be fully
// compliant w/ the diamond standard

contract DiamondClone {
    AppStorage internal s;

    constructor(address diamondSawAddress, address[] memory facetAddresses) payable {
        s.diamondSawAddress = diamondSawAddress;

        for (uint256 i; i < facetAddresses.length; i++) {
            address facetAddress = facetAddresses[i];
            _checkFacetSupported(facetAddress);
            s.facetAddresses[facetAddress] = true;
        }
    }

    function _checkFacetSupported(address facetAddress) private {
        (bool success, ) = s.diamondSawAddress.call(abi.encodeWithSignature("isFacetSupported(address)", facetAddress));
        require(success, "Facet not supported");
    }

    // calls externally to the saw to find the appropriate facet to delegate to
    function _getFacetAddressForCall() private returns (address addr) {
        (bool success, bytes memory res) = s.diamondSawAddress.call(abi.encodeWithSignature("facetAddressForSelector(bytes4)", msg.sig));
        require(success, "Failed to fetch facet address for call");

        assembly {
            addr := mload(add(res, 32))
        }
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        // TODO - implement a "gas cache" that keeps track of
        // highly trafficked write selector on the diamond itself
        // referencing the selector gas cache will be cheaper than
        // calling externally
        address facet = _getFacetAddressForCall();

        // check if the facet address exists on the saw AND is included in our local cut
        require(facet != address(0) && s.facetAddresses[facet], "Diamond: Function does not exist");

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
