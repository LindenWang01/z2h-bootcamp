// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CLXFarmingPoolReward is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public CLA = IERC20(0x7203D5cB03E889a55C455Fe9F9B91cd60D4bC883); // 质押代币
    IERC20 public CLB = IERC20(0xa53f370c3F1eA391a3219FD3c909B9a0e3fFF48D); // 奖励代币

    uint256 public constant DURATION = 100 days;
    uint256 public startTime = 1679314820; // 2023-03-20 20:20:20(UTC+8)
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0; // 奖励速度
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 private _totalSupply; // 质押CLA币种的数量
    uint256 public totalReward = totalReward.add(10000).mul(1e18); // 总计奖励CLB代币数量

    mapping(address => uint256) private _balances;
    mapping(address => uint256) public userRewardPerTokenPaid; // 用户每个代币对应奖励
    mapping(address => uint256) public rewards; // 质押挖矿奖励

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() updateReward(address(0)) {
        rewardRate = totalReward.div(DURATION);
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(totalReward);
    }

    function injectionReward() external onlyOwner {
        CLB.safeTransferFrom(msg.sender, address(this), totalReward);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(
        uint256 amount
    ) public updateReward(msg.sender) checkHalve checkStart {
        require(amount > 0, "Cannot stake 0");

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        CLA.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    ) public updateReward(msg.sender) checkHalve checkStart {
        require(amount > 0, "Cannot withdraw 0");

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        CLA.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            CLB.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    modifier checkHalve() {
        if (block.timestamp >= periodFinish) {
            totalReward = totalReward.mul(50).div(100);

            rewardRate = totalReward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(totalReward);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp > startTime, "not start");
        _;
    }
}
