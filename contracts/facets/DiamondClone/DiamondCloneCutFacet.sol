// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DiamondCloneLib.sol";
import "../AccessControl/AccessControlModifiers.sol";

// import "../utils/DiamondInitializable.sol";

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

    function setImmutableUntil(uint256 timestampSeconds) external onlyOwner {
        DiamondCloneLib.setImmutableUntil(timestampSeconds);
    }

    function immutableUntilTimestamp() internal view returns (uint256) {
        return DiamondCloneLib.immutableUntilTimestamp();
    }

    function upgradeDiamondSaw(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external onlyOwner {
        DiamondCloneLib.upgradeDiamondSaw();
    }
}
