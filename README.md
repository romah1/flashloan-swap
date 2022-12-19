# UniswapV2 flashloan swap example

This project demonstrates how to make UniswapV2 flashloan swap on mainnet fork. `contracts/FlashLoanSwap.sol` contract performs `WETH -> USDT -> LINK -> WETH` swap.

`test/FlashLoanSwap.ts` contains test that sets up the environment, calls `FlashLoanSwap` contract and prints the results to console

## How to run:
```
npm i
npx hardhat run scripts/swap.ts
```

## Output:
```
➜  flashloan_swap npx hardhat test 

  Lock
    Swap
Making WETH -> USDT -> LINK -> WETH flashloan swap
Amount of WETH loan:  BigNumber { value: "10000000000000000000" }
Amount of WETH before swap:  BigNumber { value: "10000000000000000000" }
Amount of WETH after swap:  BigNumber { value: "151143879276835978" }
Amount before swap - amount after swap:  BigNumber { value: "9848856120723164022" }
      ✔ Test flash loan swap (12741ms)


  1 passing (13s)
```
