// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayerProgress {
    struct Stats {
        uint256 score;        // Total orbs collected
        uint256 maxLevel;     // Highest level reached
    }

    mapping(address => Stats) public playerStats;

    event ProgressUpdated(address indexed player, uint256 score, uint256 maxLevel);

    /// @notice Updates the player's score and max level if they're higher than before
    function updateProgress(address player, uint256 newScore, uint256 newLevel) external {
        Stats storage stats = playerStats[player];

        if (newScore > stats.score) {
            stats.score = newScore;
        }

        if (newLevel > stats.maxLevel) {
            stats.maxLevel = newLevel;
        }

        emit ProgressUpdated(player, stats.score, stats.maxLevel);
    }

    /// @notice Get player score and max level
    function getStats(address player) external view returns (uint256 score, uint256 maxLevel) {
        Stats memory stats = playerStats[player];
        return (stats.score, stats.maxLevel);
    }
}
