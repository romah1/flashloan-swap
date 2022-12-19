import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

describe("Lock", function () {
  async function deployFlashLoanSwapFixture() {
    const [owner] = await ethers.getSigners();
    const AmountToSwap = ethers.utils.parseEther('10');

    const FlashLoanSwap = await ethers.getContractFactory("FlashLoanSwap");
    const flashLoanSwap = await FlashLoanSwap.deploy();

    return { flashLoanSwap, owner, AmountToSwap };
  }

  describe("Swap", function () {
    it("Test flash loan swap", async function () {
      const { flashLoanSwap, AmountToSwap, owner } = await loadFixture(deployFlashLoanSwapFixture);
      const weth = await ethers.getContractAt("IWETH", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
      await owner.sendTransaction({
        to: flashLoanSwap.address,
        value: AmountToSwap
      });
      await weth.deposit({
        value: AmountToSwap
      });
      await weth.transfer(flashLoanSwap.address, AmountToSwap);
      const wethERC20 = await ethers.getContractAt("IERC20", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
      const balanceBeforeSwap = await wethERC20.balanceOf(flashLoanSwap.address);
      await flashLoanSwap.testFlashSwap(AmountToSwap);
      const balanceAfterSwap = await wethERC20.balanceOf(flashLoanSwap.address);
      console.log("Making WETH -> USDT -> LINK -> WETH flashloan swap");
      console.log("Amount of WETH loan: ", AmountToSwap);
      console.log("Amount of WETH before swap: ", balanceBeforeSwap);
      console.log("Amount of WETH after swap: ", balanceAfterSwap);
      console.log("Amount before swap - amount after swap: ", balanceBeforeSwap.sub(balanceAfterSwap));
    });
  });
});
