// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AppStorage {
    // address of the diamond saw contract
    address diamondSawAddress;
    // mapping to all the facets this diamond implements.
    // because of this we don't have to store selectors
    mapping(address => bool) facetAddresses;
    // The current sale state
    uint256 saleState;
}

uint256 constant SALE_STATE_CLOSED = 0;
uint256 constant SALE_STATE_PUBLIC = 1;
