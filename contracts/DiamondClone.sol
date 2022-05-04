// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libraries/LibDiamondCloneMinimal.sol";

contract DiamondClone {
    constructor(
        address diamondSawAddress,
        address[] memory facetAddresses,
        address _init, // base facet address
        bytes memory _calldata // appropriate call data
    ) {
        // First facet should be the saw cutter facet
        (bool success, ) = facetAddresses[0].delegatecall(
            abi.encodeWithSignature("initialCut(address,address[],address,bytes)", diamondSawAddress, facetAddresses, _init, _calldata)
        );
        require(success, "Failed to cut diamond from saw");
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        // TODO - implement a "gas cache" that keeps track of
        // highly trafficked write selector on the diamond itself
        // referencing the selector gas cache will be cheaper than
        // calling externally
        address facet = LibDiamondCloneMinimal._getFacetAddressForCall();

        // check if the facet address exists on the saw AND is included in our local cut
        require(facet != address(0) && LibDiamondCloneMinimal.getDiamondCloneStorage().facetAddresses[facet], "Diamond: Function does not exist");

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
