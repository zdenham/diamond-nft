// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AllowListMintLib {
    bytes32 constant ALLOW_LIST_MINT_STORAGE_POSITION =
        keccak256("allow.list.mint.facet.storage");
    struct AllowListMintStorage {
        mapping(address => uint256) _allowList;
        uint256 allowListMintPrice;
    }

    function allowListMintStorage()
        internal
        pure
        returns (AllowListMintStorage storage es)
    {
        bytes32 position = ALLOW_LIST_MINT_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }

    function setAllowListAddress(address allowLister, uint256 amount) internal {
        allowListMintStorage()._allowList[allowLister] = amount;
    }

    function setMultipleAllowListAddresses(
        address[] memory allowListers,
        uint256 amount
    ) internal {
        AllowListMintStorage storage s = allowListMintStorage();
        for (uint256 i; i < allowListers.length; i++) {
            s._allowList[allowListers[i]] = amount;
        }
    }

    function allowListMint(uint256 count) internal {
        AllowListMintStorage storage s = allowListMintStorage();
        uint256 numAllowedMints = s._allowList[msg.sender];

        require(
            numAllowedMints >= count,
            "AllowListMint: sender does not have enough allow list entries"
        );
        require(
            msg.value >= s.allowListMintPrice * count,
            "AllowListMint: insufficient funds"
        );

        s._allowList[msg.sender] = numAllowedMints - count;

        // TODO actually mint
    }

    function numAllowListEntries(address allowLister)
        internal
        view
        returns (uint256)
    {
        return allowListMintStorage()._allowList[allowLister];
    }

    function setAllowListMintPrice(uint256 nextPrice) internal {
        allowListMintStorage().allowListMintPrice = nextPrice;
    }
}
