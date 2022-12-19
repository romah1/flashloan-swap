// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IWETH.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';


contract FlashLoanSwap is IUniswapV2Callee {
  
  IUniswapV2Router02 constant router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Factory constant factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
  address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
  address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  constructor() public {}

  receive() external payable {}

  function testFlashSwap(uint _amount) external {
    address pair = factory.getPair(WETH, USDC);
    require(pair != address(0), "!pair");

    address token0 = IUniswapV2Pair(pair).token0();
    address token1 = IUniswapV2Pair(pair).token1();
    uint amount0Out = WETH == token0 ? _amount : 0;
    uint amount1Out = WETH == token1 ? _amount : 0;

    bytes memory data = abi.encode(WETH, _amount);

    IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
  }

  function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external override {
    address token0 = IUniswapV2Pair(msg.sender).token0();
    address token1 = IUniswapV2Pair(msg.sender).token1();

    address pair = factory.getPair(token0, token1);
    require(msg.sender == pair, "!pair");
    require(_sender == address(this), "!sender");

    (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

    // WETH -> USDT -> LINK -> WETH
    address[] memory weth_usdt_path = new address[](4);
    weth_usdt_path[0] = WETH;
    weth_usdt_path[1] = USDT;
    weth_usdt_path[2] = LINK;
    weth_usdt_path[3] = WETH;
    IERC20(WETH).approve(address(router), amount);
    router.swapExactTokensForTokens(amount, 0, weth_usdt_path, address(this), now + 1e8);

    // RETURN WETH
    uint fee = ((amount * 3) / 997) + 1;
    uint amountToRepay = amount + fee;
    IERC20(tokenBorrow).transfer(pair, amountToRepay);
  }
}
