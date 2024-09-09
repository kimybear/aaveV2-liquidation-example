// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
//import "test/LiquidationBot.t.sol";
//import "test/LiqBot.t.sol";
import "../src/LiqBot.sol";

contract Broadcast is Script {
    function run() external {
        // SET UP
        address lendingPool = 0x721F0D065F30C6D4c5AD727B0c69Af3dbc858d49;
		// HONEY TOKENB
		address debtAsset = 0xfA6EC96b457250E269d7E3B0Db37aA7dCB89E7c1;
		// WBTC TOKENA
		address collateralAsset = 0x23dBAD16959cCb8Bd355854EF268ffBdba5F8FC4;
		// The address of the borrower getting liquidated
		// user 4
		address user4 = 0xa282877b05E4F9920Dc6E643eFc54beEE3E09b1E;
        address user3= 0x0148d6447bee61a5565bC9e520D898df7254a09F;
        LiqBot liqBot = new LiqBot(lendingPool, user3, user4);

        uint256 deployerPrivateKey = vm.envUint("UPK3");
        address deployer = vm.addr(deployerPrivateKey);
        address DEBT_TOKEN = 0xfA6EC96b457250E269d7E3B0Db37aA7dCB89E7c1;
        console.log("Step 1: Verifying addresses");
        console.log("Deployer address:", vm.addr(deployerPrivateKey));
        console.log("USER3 address:", user3);
        console.log("USER4 address:", user4);
        console.log("LENDING_POOL address:", lendingPool);
        console.log("DEBT_TOKEN address:", debtAsset);



        // Initialize Broadcast
        console.log("msg.sender should be deployer %s", deployer);
        console.log("msg.sender %s", msg.sender);
        console.log();

        console.log("Step 2: nvm.startBroadcast(deployerPrivateKey)...");
        vm.startBroadcast(deployerPrivateKey);
        // check health factor first
        (, , , , , uint256 healthFactor) = ILendingPool(lendingPool).getUserAccountData(user4);
		console.log("health factor in %", healthFactor/1e16);
		//assertEq(healthFactor < 1e18, true); 


        if (healthFactor < 1e18) {
            console.log("Step 3: health factor < 1, approve & trigger liquidation");
            // approve & trigger liquidation
            IERC20(debtAsset).approve(address(liqBot), type(uint256).max);
            uint256 allowance = IERC20(debtAsset).allowance(deployer, address(liqBot));
            console.log("Current allowance", allowance);
            uint256 debtBalance = IERC20(debtAsset).balanceOf(deployer);
            console.log("Current debt", debtBalance);
            IERC20(debtAsset).transfer(address(liqBot), debtBalance);
            liqBot.setAllowance(debtAsset, type(uint256).max);
            // Perform liquidation
            liqBot.checkAndLiquidateUser4(collateralAsset, debtAsset);
        }
        

        // // test liq bot
        // LiqBotTest// liqBotTest = new LiqBotTest();
        // liqBotTest.setUp();
        // IERC20(DEBT_TOKEN).approve(address(liqBotTest), type(uint256).max);
        // uint256 allowance = IERC20(DEBT_TOKEN).allowance(deployer, address(liqBotTest));
        // console.log("Current allowance", allowance);
        // uint256 debtBalance = IERC20(DEBT_TOKEN).balanceOf(deployer);
        // console.log("Current debt", debtBalance);
        // IERC20(DEBT_TOKEN).transfer(address(liqBotTest), debtBalance);
        // liqBotTest.testHealthFactor();
        // liqBotTest.testLiquidation();

        vm.stopBroadcast();
        console.log("vm.stopBroadcast()");

        // Prank
        // console.log();
        // console.log("vm.startPrank(deployer)...");
        // vm.startPrank(deployer);
        // console.log("msg.sender %s", msg.sender);
        // vm.stopPrank();
        // console.log("vm.stopPrank()");
    }


    //  function testHealthFactor() public {
	// 	(, , , , , uint256 healthFactor) = ILendingPool(lendingPool).getUserAccountData(user);
	// 	console.log("health factor in %", healthFactor/1e16);
	// 	assertEq(healthFactor < 1e18, true); 
    // }

    // function testLiquidation() public {
    //     liqBot.setAllowance(debtAsset, type(uint256).max);
    //     // Perform liquidation
    //     liqBot.checkAndLiquidateUser4(collateralAsset, debtAsset);
    // }
}