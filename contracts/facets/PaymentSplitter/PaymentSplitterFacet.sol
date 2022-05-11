// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PaymentSplitterLib} from "./PaymentSplitterLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";

contract PaymentSplitterFacet is AccessControlModifiers {
    function setPaymentSplits(PaymentSplitterLib.SplitInfo[] memory splits) external onlyOwner {
        PaymentSplitterLib.setPaymentSplits(splits);
    }

    function withdraw() external onlyAdmin {
        PaymentSplitterLib.withdraw();
    }

    function paymentSplitterInfo() public view returns (PaymentSplitterLib.SplitInfo[] memory) {
        return PaymentSplitterLib.paymentSplitterInfo();
    }
}
