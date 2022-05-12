// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondCloneLib, IDiamondCut} from "./DiamondCloneLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

contract DiamondCloneCutFacet is IDiamondCut, AccessControlModifiers {
    function initialCut(
        address diamondSawAddress,
        address[] calldata facetAddresses,
        address _init, // base facet address
        bytes calldata _calldata // appropriate call data
    ) external {
        DiamondCloneLib.initialCutWithDiamondSaw(diamondSawAddress, facetAddresses, _init, _calldata);
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override onlyOwner {
        require(!DiamondCloneLib.isImmutable(), "Cannot cut the diamond while immutable");
        DiamondCloneLib.cutWithDiamondSaw(_diamondCut, _init, _calldata);
    }

    function setGasCacheForSelector(bytes4 selector) external onlyAdmin {
        DiamondCloneLib.setGasCacheForSelector(selector);
    }

    function setImmutableUntilBlock(uint256 blockNumber) external onlyOwner {
        require(!DiamondCloneLib.isImmutable(), "Cannot cut the diamond while immutable");
        DiamondCloneLib.setImmutableUntilBlock(blockNumber);
    }

    function immutableUntilBlock() internal view returns (uint256) {
        return DiamondCloneLib.immutableUntilBlock();
    }

    function upgradeDiamondSaw(
        address[] calldata _oldFacetAddresses,
        address[] calldata _newFacetAddresses,
        address _init,
        bytes calldata _calldata
    ) external onlyOwner {
        DiamondCloneLib.upgradeDiamondSaw(_oldFacetAddresses, _newFacetAddresses, _init, _calldata);
    }
}
