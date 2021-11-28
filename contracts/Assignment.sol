// SPDX-License-Identifier: GPL-3.0

pragma solidity = 0.8.4;

interface V2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface pairContract {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

import "./interfaces/IUniswapV2Router02.sol";
import "hardhat/console.sol";

// create your own interface for the router for the swap
// swap has to be done using ETH and any other token


contract Assignment  {

    V2Factory public immutable sushiswapFactory;
    V2Factory public immutable uniswapV2Factory;
    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Router02 public immutable sushiswapV2Router;

// go to factory contract
// get the pair address
// get the reserves from the factory

    constructor (V2Factory _sushiswapFactory, V2Factory _uniswapV2Factory, IUniswapV2Router02 _uniswapV2Router, IUniswapV2Router02 _sushiswapV2Router)  {
        sushiswapFactory = _sushiswapFactory;
        uniswapV2Factory = _uniswapV2Factory;
        uniswapV2Router = _uniswapV2Router;
        sushiswapV2Router = _sushiswapV2Router;

    }

    function getQuote(address tokenIn, address tokenOut, uint tokenInQty) external returns (uint tokenOutQty, bool isUniBetter) {
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

    function swapWithOutGettingQuote(address tokenIn, address tokenOut, uint tokenInQty, uint deadline, uint minimumTokenOutQty) external {
        
    }

    function swapGettingQuote(address tokenIn, address tokenOut, uint tokenInQty, uint deadline, uint minimumTokenOutQty) external {
        
    }


}