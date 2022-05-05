// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamondClone.sol";
import "../libraries/LibAccessControl.sol";

// import "../utils/DiamondInitializable.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract DiamondCloneCutFacet is IDiamondCut {
    function initialCut(
        address diamondSawAddress,
        address[] calldata facetAddresses,
        address _init, // base facet address
        bytes calldata _calldata // appropriate call data
    ) external {
        LibDiamondClone.initialCutWithDiamondSaw(diamondSawAddress, facetAddresses, _init, _calldata);
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        LibAccessControl._enforceOwner();
        LibDiamondClone.cutWithDiamondSaw(_diamondCut, _init, _calldata);
    }
}
