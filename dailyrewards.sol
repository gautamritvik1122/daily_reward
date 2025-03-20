pragma solidity ^0.8.0;

contract DailyLoginReward {
    // Track last login timestamp for each user
    mapping(address => uint256) public lastLogin;
    
    // Store user reward balances
    mapping(address => uint256) public rewards;
    
    // Fixed reward amount (in wei)
    uint256 public constant REWARD_AMOUNT = 1000000000000000000; // 1 ETH
    
    // Minimum time between rewards (1 day in seconds)
    uint256 public constant COOLDOWN_PERIOD = 86400;
    
    // Event to track reward claims
    event RewardClaimed(address indexed user, uint256 amount, uint256 timestamp);
    
    // Function to claim daily reward
    function claimReward() public {
        address user = msg.sender;
        uint256 currentTime = block.timestamp;
        
        // Check if user can claim (first login or 24h passed)
        require(
            lastLogin[user] == 0 || 
            currentTime >= lastLogin[user] + COOLDOWN_PERIOD,
            "Can only claim once per day"
        );
        
        // Update last login time
        lastLogin[user] = currentTime;
        
        // Add reward to user's balance
        rewards[user] = rewards[user] + REWARD_AMOUNT;
        
        // Emit event
        emit RewardClaimed(user, REWARD_AMOUNT, currentTime);
    }
    
    // Function to check user's reward balance
    function getRewardBalance() public view returns (uint256) {
        return rewards[msg.sender];  // Simplified to directly use msg.sender
    }
    
    // Function to withdraw accumulated rewards
    function withdrawRewards() public {
        address user = msg.sender;
        uint256 amount = rewards[user];
        
        require(amount > 0, "No rewards to withdraw");
        
        // Reset reward balance before transfer
        rewards[user] = 0;
        
        // Transfer rewards
        payable(user).transfer(amount);
    }
    
    // Allow contract to receive ETH
    receive() external payable {}
}
