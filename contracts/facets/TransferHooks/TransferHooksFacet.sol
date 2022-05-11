// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TransferHooksLib} from "./TransferHooksLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";

contract TransferHooksFacet is AccessControlModifiers {
    function setAfterTransfersHook(address _afterTransfersHook) external onlyAdmin {
        TransferHooksLib.setAfterTransfersHook(_afterTransfersHook);
    }

    function setBeforeTransfersHook(address _beforeTransfersHook) external onlyAdmin {
        TransferHooksLib.setBeforeTransfersHook(_beforeTransfersHook);
    }
}
