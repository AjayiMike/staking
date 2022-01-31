// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract StakingPool {
  using SafeMath for uint256;
  IERC20 private skateToken;
  uint256 public totalStaked;
  uint256 public rewardRate;
  mapping(address => uint256) public userStakeBalance;
  mapping(address => uint256) public userStakingReward;
  uint256 private previouslyCalculatedReward;
  mapping(address => uint256) private previouslyCalculatedRewardStoredForUser;
  uint256 private lastUpdatedTimeStamp;

  event Stake(address indexed account, uint256 indexed amount, uint256 timestamp);
  event Unstake(address indexed account, uint256 indexed amount, uint256 timestamp);
  event RewardClaim(address indexed account, uint256 indexed amount, uint256 timestamp);

  constructor(address _skateTokenAddress, uint256 _rewardRate) {
    skateToken = IERC20(_skateTokenAddress);
    rewardRate = _rewardRate;
  }

  function getTotalReward() internal view returns(uint256) {
    if(totalStaked == 0) return 0;

    return previouslyCalculatedReward + (
        rewardRate.mul(1e18).div(totalStaked) * block.timestamp.sub(lastUpdatedTimeStamp)
      );
  }

  function getUserStakingReward(address _account) internal view returns(uint256) {
    return (userStakeBalance[_account] * previouslyCalculatedReward.sub(previouslyCalculatedRewardStoredForUser[_account])) + userStakingReward[_account];
  }

  function updateReward(address _account) internal {
    previouslyCalculatedReward = getTotalReward();
    lastUpdatedTimeStamp = block.timestamp;
    userStakingReward[_account] = getUserStakingReward(_account);

    previouslyCalculatedRewardStoredForUser[_account] = previouslyCalculatedReward;
  }

  function stake(uint256 _amount) external {
    updateReward(msg.sender);
    uint256 balance = skateToken.balanceOf(msg.sender);
    require(balance >= _amount, "Insufficient balance");
    skateToken.transferFrom(msg.sender, address(this), _amount); //the erc20 tranfer function will handle the insufficient allowance case
    userStakeBalance[msg.sender].add(_amount);
    totalStaked.add(_amount);
    emit Stake(msg.sender, _amount, block.timestamp);
  }

  function unstake(uint256 _amount) external {
    updateReward(msg.sender);
    require(userStakeBalance[msg.sender] >= _amount, "Staking pool contract: You cannot unstake more than you've staked");
    userStakeBalance[msg.sender].sub(_amount);
    totalStaked.sub(_amount);
    skateToken.transfer(msg.sender, _amount);
    emit Unstake(msg.sender, _amount, block.timestamp);
  }

  function claimReward() internal {
    updateReward(msg.sender);
    uint256 rewardAmount = userStakingReward[msg.sender];
    userStakingReward[msg.sender] = 0;
    skateToken.transfer(msg.sender, rewardAmount);
    emit RewardClaim(msg.sender, rewardAmount, block.timestamp);
  }
}
