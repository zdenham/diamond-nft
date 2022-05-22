// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721AFacet, ERC721ALib} from "./ERC721A/ERC721AFacet.sol";
import {Strings} from "./ERC721A/ERC721ALib.sol";
import {BasicAccessControlFacet} from "./AccessControl/BasicAccessControlFacet.sol";
import {AccessControlModifiers, AccessControlLib} from "./AccessControl/AccessControlModifiers.sol";
import {BaseNFTLib} from "./BaseNFTLib.sol";
import {SaleStateModifiers} from "./BaseNFTModifiers.sol";
import {URIStorageLib} from "./URIStorage/URIStorageLib.sol";
import {URIStorageFacet} from "./URIStorage/URIStorageFacet.sol";
import {PaymentSplitterFacet} from "./PaymentSplitter/PaymentSplitterFacet.sol";
import {RoyaltyStandardFacet} from "./RoyaltyStandard/RoyaltyStandardFacet.sol";

// Inherit from other facets in the BaseNFTFacet
// Why inherit to one facet instead of deploying Each Facet Separately?
// Because its cheaper for end customers to just store / cut one facet address

contract BaseNFTFacet is
    SaleStateModifiers,
    AccessControlModifiers,
    BasicAccessControlFacet,
    ERC721AFacet,
    RoyaltyStandardFacet,
    URIStorageFacet
{
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

        if (s._currentIndex == s._startIndex) {
            s._startIndex = _startIndex;
            s._currentIndex = _startIndex;
        }
    }

    function devMint(address to, uint256 quantity) public payable onlyOperator {
        BaseNFTLib._safeMint(to, quantity);
    }

    function devMintWithTokenURI(address to, string memory _tokenURI)
        public
        payable
        onlyOperator
    {
        uint256 tokenId = BaseNFTLib._safeMint(to, 1);
        URIStorageLib.setTokenURI(tokenId, _tokenURI);
    }

    function saleState() public view returns (uint256) {
        return BaseNFTLib.saleState();
    }

    function setSaleState(uint256 _saleState) public onlyOperator {
        BaseNFTLib.setSaleState(_saleState);
    }

    function setMaxMintable(uint256 _maxMintable) public onlyOperator {
        return BaseNFTLib.setMaxMintable(_maxMintable);
    }

    function maxMintable() public view returns (uint256) {
        return BaseNFTLib.maxMintable();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) {
            revert("Cannot Query tokenURI for non-existant tokenId");
        }

        return URIStorageLib.tokenURI(tokenId);
    }
}
