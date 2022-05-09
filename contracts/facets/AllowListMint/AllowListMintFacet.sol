// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleStateModifiers} from "../BaseNFTModifiers.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";
import {AllowListMintLib} from "./AllowListMintLib.sol";

contract AllowListMintFacet is SaleStateModifiers, AccessControlModifiers {
    function setAllowListAddress(address allowLister, uint256 amount) public onlyAdmin {
        AllowListMintLib.setAllowListAddress(allowLister, amount);
    }

    function setMultipleAllowListAddresses(address[] memory allowListers, uint256 amount) public onlyAdmin {
        AllowListMintLib.setMultipleAllowListAddresses(allowListers, amount);
    }

    function mintFromAllowList(uint256 count) public onlyAtSaleState(2) {
        AllowListMintLib.mintFromAllowList(count);
    }

    function numAllowListEntries(address allowLister) public view returns (uint256) {
        return AllowListMintLib.numAllowListEntries(allowLister);
    }

    function setAllowListMintPrice(uint256 nextPrice) public onlyAdmin {
        AllowListMintLib.setAllowListMintPrice(nextPrice);
    }

    function allowListMintPrice() public view returns (uint256) {
        return AllowListMintLib.allowListMintStorage().allowListMintPrice;
    }
}
