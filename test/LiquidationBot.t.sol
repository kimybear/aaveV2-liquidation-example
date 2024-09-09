// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LiquidationBot.sol";

contract LiquidationBotTest is Test {
    LiquidationBot public liquidationBot;
	address debtAsset;
	address collateralAsset;
	address user;
	address lendingPool;

    function setUp() public {
		// balancer v2 vault
		// address balancerValut = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
		// lending pool
		lendingPool = 0x721F0D065F30C6D4c5AD727B0c69Af3dbc858d49;
		liquidationBot = new LiquidationBot(lendingPool);
		// HONEY TOKENB
		debtAsset = 0xfA6EC96b457250E269d7E3B0Db37aA7dCB89E7c1;
		// WBTC TOKENA
		collateralAsset = 0x23dBAD16959cCb8Bd355854EF268ffBdba5F8FC4;
		// The address of the borrower getting liquidated
		// user 4
		user = 0xa282877b05E4F9920Dc6E643eFc54beEE3E09b1E;

	}

    // function testDebtBalance() public {
	// 	uint256 balance = IERC20(debtAsset).balanceOf(address(liquidationBot));
	// 	console.log("debtAsset balance: ", balance);
    //     assertEq(balance, 0);
    // }

    // function testCollateralAsset() public {
	// 	uint256 balance = IERC20(collateralAsset).balanceOf(address(liquidationBot));
	// 	console.log("collateralAsset balance: ", balance);
    //     assertEq(balance, 0);
    // }
    function testHealthFactor() public {
		(, , , , , uint256 healthFactor) = ILendingPool(lendingPool).getUserAccountData(user);
		console.log("health factor in %", healthFactor/1e16);
		assertEq(healthFactor < 1e18, true);
    }

	function testLiquidataionCall() public {
		//uint256 amount = 385664245699518349;
		uint256 healthFactor = liquidationBot.checkHealthFactor(user);
		console.log("healthFactor in e16 is:", healthFactor/1e16);
		assertEq(healthFactor < 1e18, true);
		//require(healthFactor < 1e18, "Health factor is above 1, cannot liquidate");

		//(uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, ,) = ILendingPool(lendingPool).getUserAccountData(user);
		//console.log("total debt:", totalDebtETH);
		uint256 debtToCover1 = type(uint256).max -1;
		//uint256 debtToCover1 = uint(-1);
		console.log("debtToCover1: ", debtToCover1);
		approveToken(debtAsset, address(lendingPool), debtToCover1);
		// liquidationBot is using wBTC & HONEY
		// liquidationBot.triggerLiquidation(collateralAsset, debtAsset, user, debtToCover1);
		ILendingPool(lendingPool).liquidationCall(
            collateralAsset,
            debtAsset,
            user,
            debtToCover1,
            false
        );

		// uint256 balance = IERC20(debtAsset).balanceOf(address(liquidationBot));
		// assertEq(balance > 0, true);
		// console.log("after liquidation, current balance ", balance);
	}

	function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "approve failed");
    }
}

