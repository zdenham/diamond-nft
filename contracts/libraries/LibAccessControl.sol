// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.0;

library LibAccessControl {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    struct AccessControlStorage {
        address _owner;
        mapping(bytes32 => RoleData) _roles;
    }

    bytes32 constant ACCESS_CONTROL_STORAGE_POSITION = keccak256("Access.Control.library.storage");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant DEFAULT_OPERATOR_ROLE = 0x00;

    function accessControlStorage() internal pure returns (AccessControlStorage storage s) {
        bytes32 position = ACCESS_CONTROL_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view {
        _checkRole(role, msg.sender);
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!_hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function _hasRole(bytes32 role, address account) internal view returns (bool) {
        return accessControlStorage()._roles[role].members[account];
    }

    function _isOwner() internal view {
        require(accessControlStorage()._owner == msg.sender, "Ownable: caller is not the owner");
    }

    function _checkOwnerOrRoles(bytes32[] memory _rolesToCheck) internal view {}
}
