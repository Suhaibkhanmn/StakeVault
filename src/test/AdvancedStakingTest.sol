// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../AdvancedStaking.sol"; // Corrected import path

contract AdvancedStakingTest is Test {
    AdvancedStaking stakingContract; // Contract instance
    address user = address(0x123); // Mock user

    function setUp() public {
        stakingContract = new AdvancedStaking(); // Deploy contract
        vm.deal(user, 100 ether); // Give mock user 100 ETH
    }

    function testStake() public {
        vm.startPrank(user); // Simulate user transaction
        stakingContract.stake{value: 1 ether}();
        vm.stopPrank();

        (uint256 amount, uint256 startTime) = stakingContract.getStakeInfo(user);

        assertEq(amount, 1 ether, "Stake amount mismatch");
        assertTrue(startTime > 0, "Start time not recorded");
    }

    function testUnstake() public {
        vm.startPrank(user);
        stakingContract.stake{value: 1 ether}();
        vm.warp(block.timestamp + 31 days); // Simulate 31 days passing
        stakingContract.unstake();
        vm.stopPrank();

        (uint256 amount, ) = stakingContract.getStakeInfo(user);
        assertEq(amount, 0, "Stake should be removed after unstaking");
    }
}
