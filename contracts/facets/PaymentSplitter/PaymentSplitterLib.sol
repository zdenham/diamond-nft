// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

uint256 constant BASIS = 10000;

library PaymentSplitterLib {
    struct SplitInfo {
        uint256 basisPoints;
        address splitAddress;
    }

    struct PaymentSplitterStorage {
        SplitInfo[] splits;
    }

    function paymentSplitterStorage() {}

    function withdraw() internal {
        uint256 balance = address(this).balance;

        // for(let)
        uint256 devPayment = (balance * _devShare) / BASIS;
        uint256 remainder = balance - devPayment;

        (bool success, ) = _devWallet.call{value: devPayment}("");
        (bool success2, ) = _wallet.call{value: remainder}("");

        require(success && success2, "Smokers: withdrawl failed");
    }
}
