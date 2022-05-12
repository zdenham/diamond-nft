// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721AFacet, ERC721ALib} from "./ERC721A/ERC721AFacet.sol";
import {Strings} from "./ERC721A/ERC721ALib.sol";
import {AccessControlFacet} from "./AccessControl/AccessControlFacet.sol";
import {AccessControlModifiers, AccessControlLib} from "./AccessControl/AccessControlModifiers.sol";
import {BaseNFTLib} from "./BaseNFTLib.sol";
import {SaleStateModifiers} from "./BaseNFTModifiers.sol";
import {URIStorageLib} from "./URIStorage/URIStorageLib.sol";
import {PaymentSplitterFacet} from "./PaymentSplitter/PaymentSplitterFacet.sol";
import {RoyaltyStandardFacet} from "./RoyaltyStandard/RoyaltyStandardFacet.sol";

// Inherit from other facets in the BaseNFTFacet
// Why inherit to one facet instead of deploying Each Facet Separately?
// Because its cheaper for end customers to just store / cut one facet address

contract BaseNFTFacet is SaleStateModifiers, AccessControlModifiers, AccessControlFacet, ERC721AFacet, PaymentSplitterFacet, RoyaltyStandardFacet {
    using Strings for uint256;

    function init() external {
        require(AccessControlLib.owner() == address(0), "Already initialized");
        AccessControlLib._transferOwnership(msg.sender);
    }

    function setTokenMeta(
        string memory _name,
        string memory _symbol,
        uint256 _startIndex
    ) public onlyOwner {
        ERC721ALib.ERC721AStorage storage s = ERC721ALib.erc721AStorage();
        s._name = _name;
        s._symbol = _symbol;

        if (s._currentIndex == 0 && _startIndex != 0) {
            s._startIndex = _startIndex;
            s._currentIndex = _startIndex;
        }
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

    function setBaseURI(string memory _baseURI) public onlyOwner {
        BaseNFTLib.setBaseURI(_baseURI);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert("Cannot Query tokenURI for non-existant tokenId");
        string storage tokenURIFromStorage = URIStorageLib.tokenURIFromStorage(tokenId);
        string storage baseURI = BaseNFTLib.baseNFTStorage().baseURI;
        // check first for URIStorage
        // then fall back on baseURI + tokenId
        return
            bytes(tokenURIFromStorage).length != 0 ? tokenURIFromStorage : bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }
}
