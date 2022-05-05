// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./SaleStateLib.sol";

abstract contract SaleStateModifiers {
    modifier atSaleStateOnly(uint256 _gatedSaleState) {
        require(_gatedSaleState == SaleStateLib.getSaleState(), "Cannot make call with current sale state");
        _;
    }

    modifier atOneOfSaleStatesOnly(uint256[] calldata _gatedSaleStates) {
        uint256 currState = SaleStateLib.getSaleState();
        for (uint256 i; i < _gatedSaleStates.length; i++) {
            if (_gatedSaleStates[i] == currState) {
                _;
                return;
            }
        }

        revert("Cannot make call with current sale state");
    }
}
