// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";
import "../libraries/LibAccessControl.sol";

contract ERC721AInit {
    // subset of ERC721 storage in same order
    struct ERC721AStorage {
        // The tokenId of the next token to be minted.
        uint256 _currentIndex;
        // The number of tokens burned.
        uint256 _burnCounter;
        // Token name
        string _name;
        // Token symbol
        string _symbol;
    }

    function erc721AStorage() internal pure returns (ERC721AStorage storage es) {
        bytes32 position = keccak256("erc721a.facet.storage");
        assembly {
            es.slot := position
        }
    }

    function init(string memory name_, string memory symbol_) external {
        LibAccessControl._transferOwnership(msg.sender);
        erc721AStorage()._name = name_;
        erc721AStorage()._symbol = symbol_;
        erc721AStorage()._currentIndex = 1;
    }
}
