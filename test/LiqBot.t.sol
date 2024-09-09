// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LiqBot.sol";

contract LiqBotTest is Test {
    LiqBot public liqBot;
	address debtAsset;
	address collateralAsset;
	address user;
	address lendingPool;
    address user3;
    address user4;

    function setUp() public {
		// balancer v2 vault
		// address balancerValut = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
		// lending pool
		lendingPool = 0x721F0D065F30C6D4c5AD727B0c69Af3dbc858d49;
		liqBot = new LiqBot(lendingPool, 0x0148d6447bee61a5565bC9e520D898df7254a09F, 0xa282877b05E4F9920Dc6E643eFc54beEE3E09b1E);
		// HONEY TOKENB
		debtAsset = 0xfA6EC96b457250E269d7E3B0Db37aA7dCB89E7c1;
		// WBTC TOKENA
		collateralAsset = 0x23dBAD16959cCb8Bd355854EF268ffBdba5F8FC4;
		// The address of the borrower getting liquidated
		// user 4
		user = 0xa282877b05E4F9920Dc6E643eFc54beEE3E09b1E;
        user3= 0x0148d6447bee61a5565bC9e520D898df7254a09F;

	}
    function testHealthFactor() public {
		(, , , , , uint256 healthFactor) = ILendingPool(lendingPool).getUserAccountData(user);
		console.log("health factor in %", healthFactor/1e16);
		assertEq(healthFactor < 1e18, true); 
    }

    function testLiquidation() public {
        liqBot.setAllowance(debtAsset, type(uint256).max);
        // Perform liquidation
        liqBot.checkAndLiquidateUser4(collateralAsset, debtAsset);
    }
    
}