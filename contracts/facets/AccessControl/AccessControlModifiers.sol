// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControlLib.sol";

abstract contract AccessControlModifiers {
    modifier onlyAdmin() {
        AccessControlLib._enforceAdmin();
        _;
    }

    modifier onlyOwner() {
        AccessControlLib._enforceOwner();
        _;
    }
}
