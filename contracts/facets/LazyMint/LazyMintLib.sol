// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721ALib} from "../ERC721A/ERC721ALib.sol";

library LazyMintLib {
    bytes32 constant LAZY_MINT_STORAGE_POSITION =
        keccak256("lazy.mint.storage");
    struct LazyMintStorage {
        uint256 publicMintPrice;
    }

    function lazyMintStorage()
        internal
        pure
        returns (LazyMintStorage storage s)
    {
        bytes32 position = LAZY_MINT_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function setPublicMintPrice(uint256 _mintPrice) internal {
        lazyMintStorage().publicMintPrice = _mintPrice;
    }

    function publicMintPrice() internal view returns (uint256) {
        return lazyMintStorage().publicMintPrice;
    }
}
