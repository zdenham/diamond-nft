// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721AFacet} from "./ERC721A/ERC721AFacet.sol";
import {ERC721ALib} from "./ERC721A/ERC721ALib.sol";
import {AccessControlFacet} from "./AccessControl/AccessControlFacet.sol";
import {AccessControlModifiers} from "./AccessControl/AccessControlModifiers.sol";
import {AccessControlLib} from "./AccessControl/AccessControlLib.sol";
import {DiamondCloneCutFacet} from "./DiamondClone/DiamondCloneCutFacet.sol";
import {DiamondCloneLoupeFacet} from "./DiamondClone/DiamondCloneLoupeFacet.sol";
import {BaseNFTLib} from "./BaseNFTLib.sol";
import {SaleStateModifiers} from "./BaseNFTModifiers.sol";

// Inherit from other facets in the BaseNFTFacet
// Why inherit to one facet instead of deploying Each Facet Separately?
// Because its cheaper for end customers to just store / cut one facet address
contract BaseNFTFacet is DiamondCloneCutFacet, DiamondCloneLoupeFacet, ERC721AFacet, SaleStateModifiers, AccessControlModifiers {
    function init(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) external {
        ERC721ALib.ERC721AStorage storage s = ERC721ALib.erc721AStorage();

        require(bytes(_symbol).length > 0, "Blank symbol");
        require(bytes(s._symbol).length == 0, "Already init");

        BaseNFTLib.setMaxSupply(_maxSupply);
        AccessControlLib._transferOwnership(msg.sender);
        s._name = _name;
        s._symbol = _symbol;
        s._currentIndex = 1;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyAdmin {
        return BaseNFTLib.setMaxSupply(_maxSupply);
    }

    function maxSupply() public view returns (uint256) {
        return BaseNFTLib.maxSupply();
    }

    function setMintPrice(uint256 _mintPrice) public onlyAdmin {
        BaseNFTLib.setMintPrice(_mintPrice);
    }

    function mintPrice() public view {
        BaseNFTLib.mintPrice();
    }

    function publicMint(uint256 quantity) public payable onlyAtSaleState(1) {
        require(msg.value >= quantity * BaseNFTLib.mintPrice(), "Insufficient funds to mint");
        BaseNFTLib._safeMint(msg.sender, quantity);
    }

    function devMint(address to, uint256 quantity) public payable onlyOwner {
        BaseNFTLib._safeMint(to, quantity);
    }

    function saleState() public view returns (uint256) {
        return BaseNFTLib.saleState();
    }

    function setSaleState(uint256 _saleState) public onlyAdmin {
        BaseNFTLib.setSaleState(_saleState);
    }
}
