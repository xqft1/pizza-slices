// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ILpRewardDistributor {
    function notifyRewardAmount(uint256 amount) external;
}