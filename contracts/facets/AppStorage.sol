// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Compiler will pack this into a single 256bit word.
struct TokenOwnership {
    // The address of the owner.
    address addr;
    // Keeps track of the start time of ownership with minimal overhead for tokenomics.
    uint64 startTimestamp;
    // Whether the token has been burned.
    bool burned;
}

// Compiler will pack this into a single 256bit word.
struct AddressData {
    // Realistically, 2**64-1 is more than enough.
    uint64 balance;
    // Keeps track of mint count with minimal overhead for tokenomics.
    uint64 numberMinted;
    // Keeps track of burn count with minimal overhead for tokenomics.
    uint64 numberBurned;
    // For miscellaneous variable(s) pertaining to the address
    // (e.g. number of whitelist mint slots used).
    // If there are multiple variables, please pack them into a uint64.
    uint64 aux;
}

struct AppStorage {
  // address of the diamond saw contract
  address diamondSawAddress;

  // IMPORTANT!!! check this out
  // mapping to all the facets this diamond implements.
  // because of this we don't have to store selectors
  mapping(address => bool) facetAddresses;

  // The tokenId of the next token to be minted.
  uint256  _currentIndex;

  // The number of tokens burned.
  uint256  _burnCounter;

  // Token name
  string _name;

  // Token symbol
  string _symbol;

  // Mapping from token ID to ownership details
  // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
  mapping(uint256 => TokenOwnership)  _ownerships;

  // Mapping owner address to address data
  mapping(address => AddressData) _addressData;

  // Mapping from token ID to approved address
  mapping(uint256 => address) _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) _operatorApprovals;

  // The current sale state
  uint256 saleState;

  // public mint price
  uint256 publicMintPrice;
}

uint256 constant SALE_STATE_CLOSED = 0;
uint256 constant SALE_STATE_PUBLIC = 1;