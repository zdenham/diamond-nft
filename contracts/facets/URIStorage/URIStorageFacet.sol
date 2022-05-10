// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {URIStorageLib} from "./URIStorageLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";

contract URIStorageFacet is AccessControlModifiers {
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyAdmin {
        URIStorageLib._setTokenURI(tokenId, _tokenURI);
    }
}
