// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721ALib} from "./ERC721A/ERC721ALib.sol";

library BaseNFTLib {
    struct BaseNFTStorage {
        uint256 maxSupply;
        bool maxSupplyLocked;
        uint256 mintPrice;
        uint256 saleState;
        string baseURI;
    }

    function baseNFTStorage() internal pure returns (BaseNFTStorage storage es) {
        bytes32 position = keccak256("base.nft.storage");
        assembly {
            es.slot := position
        }
    }

    function maxSupply() internal view returns (uint256) {
        return baseNFTStorage().maxSupply;
    }

    function setMaxSupply(uint256 _maxSupply) internal {
        require(_maxSupply <= ERC721ALib.totalSupply(), "Cannot set max supply less than total supply");
        require(!baseNFTStorage().maxSupplyLocked, "Max supply has been locked");

        baseNFTStorage().maxSupply = _maxSupply;
    }

    function setMintPrice(uint256 _mintPrice) internal {
        baseNFTStorage().mintPrice = _mintPrice;
    }

    function mintPrice() internal view returns (uint256) {
        return baseNFTStorage().mintPrice;
    }

    function _safeMint(address to, uint256 quantity) internal {
        uint256 max = baseNFTStorage().maxSupply;
        require(max == 0 || max > (ERC721ALib.totalSupply() + quantity), "Mint exceeds max supply");
        ERC721ALib._safeMint(to, quantity);
    }

    function saleState() internal view returns (uint256) {
        return baseNFTStorage().saleState;
    }

    function setSaleState(uint256 _saleState) internal {
        baseNFTStorage().saleState = _saleState;
    }

    function setBaseURI(string memory _baseURI) internal {
        baseNFTStorage().baseURI = _baseURI;
    }
}
