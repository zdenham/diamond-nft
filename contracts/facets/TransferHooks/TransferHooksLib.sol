// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondCloneLib} from "../DiamondClone/DiamondCloneLib.sol";
import {DiamondSaw} from "../../DiamondSaw.sol";

library TransferHooksLib {
    struct TransferHooksStorage {
        address beforeTransfersHook;
        address afterTransfersHook;
    }

    function transferHooksStorage() internal pure returns (TransferHooksStorage storage s) {
        bytes32 position = keccak256("transfer.hooks.facet.storage");
        assembly {
            s.slot := position
        }
    }

    function setBeforeTransfersHook(address _beforeTransfersHook) internal {
        address sawAddress = DiamondCloneLib.diamondCloneStorage().diamondSawAddress;
        bool isApproved = DiamondSaw(sawAddress).isTransferHooksContractApproved(_beforeTransfersHook);
        require(isApproved, "before transfer hook contract not approved");
        transferHooksStorage().beforeTransfersHook = _beforeTransfersHook;
    }

    function setAfterTransfersHook(address _afterTransfersHook) internal {
        address sawAddress = DiamondCloneLib.diamondCloneStorage().diamondSawAddress;
        bool isApproved = DiamondSaw(sawAddress).isTransferHooksContractApproved(_afterTransfersHook);
        require(isApproved, "after transfer hook contract not approved");
        transferHooksStorage().afterTransfersHook = _afterTransfersHook;
    }

    function beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal {
        TransferHooksStorage storage s = transferHooksStorage();

        if (s.beforeTransfersHook == address(0)) {
            return;
        }

        (bool success, ) = s.afterTransfersHook.call(
            abi.encodeWithSignature("beforeTokenTransfers(address, address, uint256, uint256)", from, to, startTokenId, quantity)
        );

        require(success, "Before transfer hook failed");
    }

    function afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal {
        TransferHooksStorage storage s = transferHooksStorage();

        if (s.afterTransfersHook == address(0)) {
            return;
        }

        (bool success, ) = s.afterTransfersHook.call(
            abi.encodeWithSignature("afterTokenTransfers(address, address, uint256, uint256)", from, to, startTokenId, quantity)
        );

        require(success, "After transfer hook failed");
    }
}
