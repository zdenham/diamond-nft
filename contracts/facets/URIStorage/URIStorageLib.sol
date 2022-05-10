// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library URIStorageLib {
    struct URIStorage {
        mapping(uint256 => string) _tokenURIs;
    }

    function uriStorage() internal pure returns (URIStorage storage s) {
        bytes32 position = keccak256("uri.storage.facet.storage");
        assembly {
            s.slot := position
        }
    }

    function tokenURIFromStorage(uint256 tokenId) internal view returns (string storage) {
        return uriStorage()._tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        uriStorage()._tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal {
        URIStorage storage s = uriStorage();
        if (bytes(s._tokenURIs[tokenId]).length != 0) {
            delete s._tokenURIs[tokenId];
        }
    }
}
