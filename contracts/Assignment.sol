// SPDX-License-Identifier: GPL-3.0

pragma solidity = 0.8.4;

interface V2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface pairContract {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

import "./interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "hardhat/console.sol";

// create your own interface for the router for the swap
// swap has to be done using ETH and any other token


contract Assignment  {

    V2Factory public constant sushiswapFactory = V2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    V2Factory public constant uniswapV2Factory = V2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 public constant sushiswapV2Router = IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    function getQuote(address tokenIn, address tokenOut, uint tokenInQty) public returns (uint tokenOutQty, bool isUniBetter) {
        //going to factories to get the pair address
        pairContract UniPairContractAddress = pairContract(uniswapV2Factory.getPair(tokenIn, tokenOut));
        pairContract SushiPairContractAddress = pairContract(sushiswapFactory.getPair(tokenIn, tokenOut));

        //getting reserves
        (uint uniReserveA, uint uniReserveB, uint uniBlocktimestamp) = UniPairContractAddress.getReserves();
        (uint sushiReserveA, uint sushiReserveB, uint sushiBlocktimestamp) = SushiPairContractAddress.getReserves();


        // getting quotes
        uint uniTokenOutQty = uniswapV2Router.quote(tokenInQty, uniReserveA, uniReserveB);
        uint sushiTokenOutQty = sushiswapV2Router.quote(tokenInQty, sushiReserveA, sushiReserveB);
        if (uniTokenOutQty > sushiTokenOutQty) {
            tokenOutQty = uniTokenOutQty;
            isUniBetter = true;
        } else {
            tokenOutQty = sushiTokenOutQty;
            isUniBetter = false;
        }

    }


    function simpleSwap(address tokenIn, address tokenOut, uint tokenInQty, uint deadline, uint minimumTokenOutQty) external {
        (uint tokenOutQty, bool isUniBetter) = getQuote(tokenIn, tokenOut, tokenInQty);
        IERC20(tokenIn).transferFrom(msg.sender, address(this), tokenInQty);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        if (isUniBetter) {
            IERC20(tokenIn).approve(address(uniswapV2Router), tokenInQty);
            uniswapV2Router.swapExactTokensForTokens(tokenInQty, minimumTokenOutQty, path, msg.sender, deadline);
        } else {
            IERC20(tokenIn).approve(address(sushiswapV2Router), tokenInQty);
            sushiswapV2Router.swapExactTokensForTokens(tokenInQty, minimumTokenOutQty, path, msg.sender, deadline);
        }
        
    }


}