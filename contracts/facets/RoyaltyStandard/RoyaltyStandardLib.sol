// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
library RoyaltyStandardLib {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    struct RoyaltyStandardStorage {
        RoyaltyInfo _defaultRoyaltyInfo;
        mapping(uint256 => RoyaltyInfo) _tokenRoyaltyInfo;
    }

    function royaltyStandardStorage() internal pure returns (RoyaltyStandardStorage storage s) {
        bytes32 position = keccak256("royalty.standard.facet.storage");
        assembly {
            s.slot := position
        }
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) internal view returns (address, uint256) {
        RoyaltyStandardStorage storage s = royaltyStandardStorage();

        RoyaltyInfo memory royalty = s._tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = s._defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `feeNumerator` cannot be greater than the fee denominator.
     * - receiver is always the contract address where payment splitting is implemented
     */
    function _setDefaultRoyalty(uint96 feeNumerator) internal {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");

        royaltyStandardStorage()._defaultRoyaltyInfo = RoyaltyInfo(address(this), feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal {
        delete royaltyStandardStorage()._defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        royaltyStandardStorage()._tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal {
        delete royaltyStandardStorage()._tokenRoyaltyInfo[tokenId];
    }
}
