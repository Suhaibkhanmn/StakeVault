// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AdvancedStaking {
    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    uint256 public constant BASE_REWARD_RATE = 5; // 5% per staking cycle
    uint256 public constant BONUS_MULTIPLIER = 2; // 2x bonus if staked beyond threshold
    uint256 public constant EARLY_UNSTAKE_PENALTY = 10; // 10% penalty for early unstaking
    uint256 public constant STAKING_THRESHOLD = 30 days; // Bonus after 30 days

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount, uint256 reward, uint256 timestamp);

    function stake() external payable {
        require(msg.value > 0, "Cannot stake 0 ETH");
        require(stakes[msg.sender].amount == 0, "Already staking");

        stakes[msg.sender] = Stake(msg.value, block.timestamp);
        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    function unstake() external {
        Stake memory userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No active stake");

        uint256 stakingDuration = block.timestamp - userStake.startTime;
        uint256 reward = calculateReward(userStake.amount, stakingDuration);

        uint256 finalAmount = userStake.amount + reward;
        delete stakes[msg.sender];

        payable(msg.sender).transfer(finalAmount);
        emit Unstaked(msg.sender, userStake.amount, reward, block.timestamp);
    }

    function calculateReward(uint256 _amount, uint256 _duration) internal pure returns (uint256) {
        uint256 rewardRate = BASE_REWARD_RATE;

        if (_duration >= STAKING_THRESHOLD) {
            rewardRate *= BONUS_MULTIPLIER; // Apply bonus
        } else {
            rewardRate = (rewardRate * (100 - EARLY_UNSTAKE_PENALTY)) / 100; // Apply penalty
        }

        return (_amount * rewardRate) / 100;
    }

    function getStakeInfo(address _user) external view returns (uint256 amount, uint256 startTime) {
        return (stakes[_user].amount, stakes[_user].startTime);
    }

    receive() external payable {
        this.stake();
    }
}
