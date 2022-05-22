// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";
import {SaleStateModifiers} from "../BaseNFTModifiers.sol";
import {LazyMintLib} from "./LazyMintLib.sol";
import {BaseNFTLib} from "../BaseNFTLib.sol";

contract LazyMintFacet is AccessControlModifiers, SaleStateModifiers {
    function setPublicMintPrice(uint256 _mintPrice) public onlyOperator {
        LazyMintLib.setPublicMintPrice(_mintPrice);
    }

    function publicMintPrice() public view {
        LazyMintLib.publicMintPrice();
    }

    function publicMint(uint256 quantity) public payable onlyAtSaleState(1) {
        require(
            msg.value >= quantity * LazyMintLib.publicMintPrice(),
            "Insufficient funds to mint"
        );
        BaseNFTLib._safeMint(msg.sender, quantity);
    }
}
