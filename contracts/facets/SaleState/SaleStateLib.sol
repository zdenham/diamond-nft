// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// Allows for different sale states of the contract
// 0 - CLOSED
// 1 - PUBLIC_SALE
// 2 - ??? Up to facets to implement

library SaleStateLib {
    struct SaleStateStorage {
        uint256 saleState;
    }

    function getSaleStateStorage() internal pure returns (SaleStateStorage storage s) {
        bytes32 position = keccak256("sale.state.facet.storage");
        assembly {
            s.slot := position
        }
    }

    function getSaleState() internal view returns (uint256) {
        return getSaleStateStorage().saleState;
    }

    function setSaleState(uint256 _saleState) internal {
      getSaleStateStorage().saleState = _saleState;
    }
}
