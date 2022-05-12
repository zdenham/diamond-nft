// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.0;

library AccessControlLib {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct AccessControlStorage {
        address _owner;
        mapping(address => bool) _admins;
    }

    bytes32 constant ACCESS_CONTROL_STORAGE_POSITION = keccak256("Access.Control.library.storage");

    function accessControlStorage() internal pure returns (AccessControlStorage storage s) {
        bytes32 position = ACCESS_CONTROL_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function _isOwner() internal view returns (bool) {
        return accessControlStorage()._owner == msg.sender;
    }

    function owner() internal view returns (address) {
        return accessControlStorage()._owner;
    }

    function _enforceOwner() internal view {
        require(_isOwner(), "Caller is not the owner");
    }

    function _isAdmin() internal view returns (bool) {
        return accessControlStorage()._admins[msg.sender];
    }

    function _enforceAdmin() internal view {
        require(_isAdmin() || _isOwner(), "Is not admin or owner");
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = accessControlStorage()._owner;
        accessControlStorage()._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
