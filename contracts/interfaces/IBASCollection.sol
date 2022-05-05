// SPDX-License-Identifier: MIT LICENSE
pragma solidity >=0.8.0;

interface IBASCollection {
    function getCollectableRarity(uint256 token)
        external
        view
        returns (uint256 rarity);
}
