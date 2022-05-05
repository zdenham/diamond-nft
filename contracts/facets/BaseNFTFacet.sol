// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ERC721A/ERC721AFacet.sol";
import "./SaleState/SaleStateFacet.sol";
import "./SaleState/SaleStateModifiers.sol";
import "./AccessControl/AccessControlFacet.sol";
import "./AccessControl/AccessControlModifiers.sol";
import "./DiamondClone/DiamondCloneCutFacet.sol";
import "./DiamondClone/DiamondCloneLoupeFacet.sol";
import "./BaseNFTLib.sol";

// Inherit from other facets in the BaseNFTFacet
// Why inherit to one facet instead of deploying Each Facet Separately?
// Because its cheaper for end customers to just store / cut one facet address
contract BaseNFTFacet is
    ERC721AFacet,
    DiamondCloneCutFacet,
    DiamondCloneLoupeFacet,
    SaleStateFacet,
    AccessControlFacet,
    SaleStateModifiers,
    AccessControlModifiers
{
    function setMaxSupply(uint256 _maxSupply) public onlyAdmin {
        return BaseNFTLib.setMaxSupply(_maxSupply);
    }

    function maxSupply() public view {
        return BaseNFTLib.maxSupply();
    }

    function setMintPrice(uint256 _mintPrice) public onlyAdmin {
        BaseNFTLib.setMintPrice(_mintPrice);
    }

    function mintPrice() public view {
        BaseNFTLib.mintPrice();
    }

    function publicMint(uint256 quantity) public payable atSaleState(1) {
        require(msg.value >= quantity * ERC721ALib.erc721AStorage().mintPrice, "Insufficient funds to mint");
        BaseNFTLib._safeMint(msg.sender, quantity);
    }

    function devMint(address to, uint256 quantity) public payable onlyOwner {
        BaseNFTLib._safeMint(to, quantity);
    }
}
