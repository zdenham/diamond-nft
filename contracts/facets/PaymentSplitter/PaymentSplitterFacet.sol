// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PaymentSplitterLib, IERC20} from "./PaymentSplitterLib.sol";
import {AccessControlModifiers} from "../AccessControl/AccessControlModifiers.sol";
import {DiamondInitializable} from "../../utils/DiamondInitializable.sol";

contract PaymentSplitterFacet is AccessControlModifiers, DiamondInitializable {
    function setPaymentSplits(address[] memory payees, uint256[] memory shares_)
        external
        onlyOwner
        initializer("payment.splitter")
    {
        PaymentSplitterLib.setPaymentSplits(payees, shares_);
    }

    function releaseToken(IERC20 token, address account) external {
        PaymentSplitterLib.release(token, account);
    }

    function release(address payable account) external {
        PaymentSplitterLib.release(account);
    }

    function payee(uint256 index) public view returns (address) {
        return PaymentSplitterLib.payee(index);
    }

    function releasedToken(IERC20 token, address account)
        public
        view
        returns (uint256)
    {
        return PaymentSplitterLib.released(token, account);
    }

    function released(address account) public view returns (uint256) {
        return PaymentSplitterLib.released(account);
    }

    function shares(address account) public view returns (uint256) {
        return PaymentSplitterLib.shares(account);
    }

    function totalReleasedToken(IERC20 token) public view returns (uint256) {
        return PaymentSplitterLib.totalReleased(token);
    }

    function totalReleased() public view returns (uint256) {
        return PaymentSplitterLib.totalReleased();
    }

    function totalShares() public view returns (uint256) {
        return PaymentSplitterLib.totalShares();
    }

    receive() external payable {
        PaymentSplitterLib.receivePayment();
    }
}
