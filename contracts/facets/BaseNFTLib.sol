// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ERC721A/ERC721ALib.sol";

library BaseNFTLib {
    struct BaseNFTStorage {
        uint256 maxSupply;
        bool maxSupplyLocked;
        uint256 mintPrice;
    }

    function baseNFTStorage() internal pure returns (BaseNFTStorage storage es) {
        bytes32 position = keccak256("erc721a.facet.storage");
        assembly {
            es.slot := position
        }
    }

    function getMaxSupply() internal view returns (uint256) {
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

    function mintPrice(uint256) internal view returns (uint256) {
        return baseNFTStorage().mintPrice;
    }

    function _safeMint(address to, uint256 quantity) internal {
        require(baseNFTStorage().maxSupply > ERC721ALib.totalSupply() + quantity, "Mint exceeds max supply");
        ERC721ALib._safeMint(to, quantity);
    }
}
