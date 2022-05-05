// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./SaleStateLib.sol";
import "../AccessControl/AccessControlModifiers.sol";

contract SaleStateFacet is AccessControlModifiers {
    function saleState() public view returns (uint256) {
        return SaleStateLib.getSaleState();
    }

    function setSaleState(uint256 _saleState) public onlyAdmin {
        SaleStateLib.setSaleState(_saleState);
    }
}
