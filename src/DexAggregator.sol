// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IUniswapV2Router01{
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
        ) external returns (uint256[] memory amounts);


    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
         ) external view returns (uint256[] memory amounts);
}


contract DexAggregator {

    error DexAggregator__InvalidDexId();
    error DexAggregator__MustBeExactlyTwoTokens();
    error DexAggregator__InvalidAmountIn();


    address public constant UNISWAP_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant SUSHISWAP = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;


    function swap(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint8 dexId
          ) external returns (uint256 amountOut) {
        
        if (dexId > 1) {
            revert DexAggregator__InvalidDexId();
        }
        if(path.length != 2) {
            revert DexAggregator__MustBeExactlyTwoTokens();
        }
        if(amountIn == 0) {
            revert DexAggregator__InvalidAmountIn();
        }

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        address router = dexId == 0 ? UNISWAP_V2 : SUSHISWAP;
        

        IERC20(path[0]).approve(router, amountIn);
        

        uint256[] memory amounts = IUniswapV2Router01(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 300
             );
        
        amountOut = amounts[1];

    }
}
