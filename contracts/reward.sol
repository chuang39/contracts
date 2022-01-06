pragma solidity ^0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./commons/Ownable.sol";

abstract contract ERC20 {
    function allowance(address owner, address spender)  virtual external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) virtual external returns (bool) ;
    function transfer(address recipient, uint256 amount) public virtual returns (bool);
    function hasRole(bytes32 role, address account) virtual external view returns (bool);
    function mint(address to, uint256 amount) public virtual;

}

contract Reward is Ownable {
  using SafeMath for uint256;
  using Address for address;

  mapping (int => uint256) public seasonOverallRewards;
  mapping (int => uint256) public seasonRewardStartTime;
  // User reward by season
  mapping (int => mapping(address => uint256)) public userRewards;
  // mapping between season and reward start time
  mapping (int => mapping(address => uint256)) public nextRewardTime;
  ERC20 _spay;
  uint256 public payoffPeriodInDays;
  uint256 public payoffTimes;

  constructor (
      uint256 _payoffPeriodInDays,
      uint256 _payoffTimes,
      address _rewardToken
  ) {
      payoffPeriodInDays = _payoffPeriodInDays;
      payoffTimes = _payoffTimes;
      _spay=ERC20(_rewardToken);
  }

  function batchAddUserRewards(int season, uint256 startTime, address[] memory users, uint[] memory rewards) external onlyOwner {
    require(users.length == rewards.length, "users length doesn't match rewards length");

    for (uint i = 0; i < users.length; i++) {
        address user = users[i];
        userRewards[season][user] = rewards[i];
        nextRewardTime[season][user] = startTime;
        seasonRewardStartTime[season] = startTime;
    }
  }

  function claim(int season) external {
      address user = _msgSender();
      require(block.timestamp >= nextRewardTime[season][user], "Next reward is not ready");
      require(nextRewardTime[season][user] < seasonRewardStartTime[season].add(payoffPeriodInDays*1 days), "Next reward is not ready");

      uint256 coolingPeriodInDays = payoffPeriodInDays.div(payoffTimes);
      uint256 portion = block.timestamp.sub(nextRewardTime[season][user]).div(coolingPeriodInDays*1 days).add(1);
      if (portion > payoffTimes) {
          portion = payoffTimes;
      }

      uint256 unitReward = userRewards[season][user].div(payoffTimes);
      uint256 totalReward = unitReward.mul(portion);

      require(_spay.transfer(user, totalReward), "Transfer failed");
      nextRewardTime[season][user] = nextRewardTime[season][user].add(portion.mul(coolingPeriodInDays*1 days));
  }

  function setSeasonOverallReward(int season, uint256 reward) external onlyOwner {
      seasonOverallRewards[season] = reward;
  }

  function setPayoffTimes(uint256 _payoffTimes) external onlyOwner {
      payoffTimes = _payoffTimes;
  }

  function setPayoffPeriodInDays(uint256 _payoffPeriodInDays) external onlyOwner {
      payoffPeriodInDays = _payoffPeriodInDays;
  }

  function setTokenAddress(address _tokenAddress) external onlyOwner {
      _spay = ERC20(_tokenAddress);
  }
}