// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {ERC721ALib} from "./ERC721A/ERC721ALib.sol";

library BaseNFTLib {
    struct BaseNFTStorage {
        uint256 saleState;
        uint256 maxMintable; // the max number of tokens able to be minted
        bool maxMintableLocked;
    }

    function baseNFTStorage()
        internal
        pure
        returns (BaseNFTStorage storage es)
    {
        bytes32 position = keccak256("base.nft.storage");
        assembly {
            es.slot := position
        }
    }

    function saleState() internal view returns (uint256) {
        return baseNFTStorage().saleState;
    }

    function setSaleState(uint256 _saleState) internal {
        baseNFTStorage().saleState = _saleState;
    }

    function _safeMint(address to, uint256 quantity)
        internal
        returns (uint256 initialTokenId)
    {
        // if max mintable is zero, unlimited mints are allowed
        uint256 max = baseNFTStorage().maxMintable;
        require(
            max == 0 || max >= (ERC721ALib.totalMinted() + quantity),
            "Mint exceeds max supply"
        );

        // returns the id of the first token minted!
        initialTokenId = ERC721ALib.currentIndex();
        ERC721ALib._safeMint(to, quantity);
    }

    function maxMintable() internal view returns (uint256) {
        return baseNFTStorage().maxMintable;
    }

    function setMaxMintable(uint256 _maxMintable) internal {
        require(
            _maxMintable <= ERC721ALib.totalMinted(),
            "Cannot set max supply less than total supply"
        );
        require(
            !baseNFTStorage().maxMintableLocked,
            "Max supply has been locked"
        );

        baseNFTStorage().maxMintable = _maxMintable;
    }
}
