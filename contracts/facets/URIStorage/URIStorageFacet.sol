// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {URIStorageLib} from "./URIStorageLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";

contract URIStorageFacet is AccessControlModifiers {
    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyOperator
    {
        URIStorageLib.setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory _baseURI) public onlyOperator {
        URIStorageLib.setBaseURI(_baseURI);
    }

    function lockMetadata() public onlyOwner {
        URIStorageLib.lockMetadata();
    }
}
