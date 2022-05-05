// SPDX-License-Identifier: MIT LICENSE
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './interfaces/IApeNFT.sol';
import './interfaces/IBASCollection.sol';

contract ApeLevel is Ownable, Pausable {
    /* ======== STATS ======== */
    uint256 constant RARIRY_FACTOR = 39731;
    uint256 constant TIME_IN_WEEK = 7 days;

    IApeNFT public apeNFT;
    IBASCollection public basCollection;

    // start timestamp
    uint256 public immutable startTime;

    // Gamester tokenId => used to level up Ape
    mapping(uint256 => uint256) gamesterIdToLevelsUsed;

    /* ======= CONSTRUCTOR ======= */
    constructor(address _apeNFT, address _basCollection) {
        require(_apeNFT != address(0), 'Invalid ApeNFT');
        require(_basCollection != address(0), 'Invalid BASCollection');

        apeNFT = IApeNFT(_apeNFT);
        basCollection = IBASCollection(_basCollection);

        startTime = block.timestamp;
    }

    ///////////////////////////////////////////////////////
    //                  VIEW FUNCTIONS                   //
    ///////////////////////////////////////////////////////

    /**
     * Compares how many levels an NFT has eanred so far
     */
    function levelsPerNFT(uint256 _tokenId) public view returns (uint256) {
        uint256 rarityCoefficient = basCollection.getCollectableRarity(
            _tokenId
        );
        uint256 multiplier;

        if (rarityCoefficient < RARIRY_FACTOR) {
            multiplier = 2;
        } else {
            multiplier = 1;
        }

        return
            (((block.timestamp - startTime) / TIME_IN_WEEK) * multiplier) -
            gamesterIdToLevelsUsed[_tokenId];
    }

    ///////////////////////////////////////////////////////
    //               GAME CALLED FUNCTIONS               //
    ///////////////////////////////////////////////////////

    /**
     * Adds levels based on levelsPerNFT
     */
    function addLevels(
        uint256 _gamesterTokenId,
        uint256 _apeTokenId,
        uint256 _levels
    ) external {
        require(
            levelsPerNFT(_gamesterTokenId) >= _levels,
            'Unavailble to add levels'
        );

        // update gamester used to level up Ape
        gamesterIdToLevelsUsed[_gamesterTokenId] += _levels;

        // ApeNFT levelup
        apeNFT.levelUp(_apeTokenId, _levels);
    }

    ///////////////////////////////////////////////////////
    //               MANAGER CALLED FUNCTIONS            //
    ///////////////////////////////////////////////////////

    function pause() external onlyOwner whenNotPaused {
        return _pause();
    }

    function unpause() external onlyOwner whenPaused {
        return _unpause();
    }
}
