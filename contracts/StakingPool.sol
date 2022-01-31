// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract StakingPool {
  using SafeMath for uint256;
  IERC20 internal skateToken;
  uint256 public totalStaked;
  uint256 public rewardRate;
  mapping(address => uint256) public userStakeBalance;
  mapping(address => uint256) public userStakingReward;
  uint256 internal lastUpdatedTime;

  event Stake(address indexed account, uint256 indexed amount, uint256 timestamp);
  event Unstake(address indexed account, uint256 indexed amount, uint256 timestamp);
  event rewardClaim(address indexed account, uint256 indexed amount, uint256 timestamp);

  constructor(address _skateTokenAddress, uint256 _rewardRate) {
    skateToken = IERC20(_skateTokenAddress);
    rewardRate = _rewardRate;
  }

  function updateReward(address _account) internal {

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
    require(userStakeBalance[msg.sender] >= _amount, "Staking pool: You cannot unstake more than you've staked");
    userStakeBalance[msg.sender].sub(_amount);
    totalStaked.sub(_amount);
    skateToken.transfer(msg.sender, _amount);
    emit Unstake(msg.sender, _amount, block.timestamp);
  }

  function claimReward(address staker) internal {
    updateReward(msg.sender);
  }
}
