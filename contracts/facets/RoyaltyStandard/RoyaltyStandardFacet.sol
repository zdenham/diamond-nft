// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";

import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";
import {RoyaltyStandardLib} from "./RoyaltyStandardLib.sol";

contract RoyaltyStandardFacet is IERC2981, AccessControlModifiers {
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address, uint256) {
        return RoyaltyStandardLib.royaltyInfo(tokenId, salePrice);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        RoyaltyStandardLib._setDefaultRoyalty(receiver, feeNumerator);
    }
}
