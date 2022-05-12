// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondCloneLib} from "../DiamondClone/DiamondCloneLib.sol";

uint256 constant BASIS = 10000;

library PaymentSplitterLib {
    struct SplitInfo {
        uint256 basisPoints;
        address payable splitAddress;
    }

    struct PaymentSplitterStorage {
        SplitInfo[] splits;
    }

    function paymentSplitterStorage() internal pure returns (PaymentSplitterStorage storage es) {
        bytes32 position = keccak256("payment.splitter.facet.storage");
        assembly {
            es.slot := position
        }
    }

    function paymentSplitterInfo() internal view returns (SplitInfo[] storage) {
        return paymentSplitterStorage().splits;
    }

    function setPaymentSplits(SplitInfo[] memory splits) internal {
        require(splits.length > 0, "Must provide split information");
        PaymentSplitterStorage storage s = paymentSplitterStorage();

        if (s.splits.length > 0) {
            require(
                s.splits[0].basisPoints == splits[0].basisPoints && s.splits[0].splitAddress == splits[0].splitAddress,
                "Cannot modify first split"
            );
        }

        uint256 total;
        for (uint256 i; i < s.splits.length; i++) {
            if (i < splits.length) {
                require(splits[i].splitAddress != address(0), "Cannot set payment split to null address");
                total += splits[i].basisPoints;
                s.splits.push(splits[i]);
            } else {
                delete splits[i];
            }
        }

        require(total == BASIS, "payment split does not add up to basis");
    }

    function withdraw() internal {
        PaymentSplitterStorage storage s = paymentSplitterStorage();
        uint256 balance = address(this).balance;

        for (uint256 i; i < s.splits.length; i++) {
            uint256 payment = (balance * s.splits[i].basisPoints) / BASIS;
            (bool success, ) = s.splits[i].splitAddress.call{value: payment}("");
            require(success, "Payment failed!");
        }
    }
}
