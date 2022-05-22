// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Strings} from "../ERC721A/ERC721ALib.sol";

library URIStorageLib {
    using Strings for uint256;

    struct URIStorage {
        mapping(uint256 => string) _tokenURIs;
        string baseURI;
        bool metadataLocked;
    }

    function uriStorage() internal pure returns (URIStorage storage s) {
        bytes32 position = keccak256("uri.storage.facet.storage");
        assembly {
            s.slot := position
        }
    }

    function setBaseURI(string memory _baseURI) internal {
        URIStorage storage s = uriStorage();
        require(!s.metadataLocked, "Cannot update base URI, metadata locked");
        s.baseURI = _baseURI;
    }

    function tokenURIFromStorage(uint256 tokenId)
        internal
        view
        returns (string storage)
    {
        return uriStorage()._tokenURIs[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        URIStorage storage s = uriStorage();
        require(!s.metadataLocked, "Cannot update token URI, metadata locked");
        s._tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal {
        URIStorage storage s = uriStorage();
        if (bytes(s._tokenURIs[tokenId]).length != 0) {
            delete s._tokenURIs[tokenId];
        }
    }

    function tokenURI(uint256 tokenId) internal view returns (string memory) {
        string storage individualTokenUri = tokenURIFromStorage(tokenId);
        string storage baseURI = uriStorage().baseURI;

        // check first for URIStorage
        // then fall back on baseURI + tokenId
        // this allows admins to set a folder for the tokens
        // but also update individual tokens i.e. for 1:1s
        // within a larger collection
        return
            bytes(individualTokenUri).length != 0
                ? individualTokenUri
                : bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function lockMetadata() internal {
        uriStorage().metadataLocked = true;
    }
}
