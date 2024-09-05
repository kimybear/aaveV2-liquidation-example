// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "test/LiquidationBot.t.sol";

contract Broadcast is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("UPK3");
        address deployer = vm.addr(deployerPrivateKey);

        // Initial 
        console.log("msg.sender should be deployer %s", deployer);
        console.log("msg.sender %s", msg.sender);
        
        // Broadcast
        console.log();
        console.log("nvm.startBroadcast(deployerPrivateKey)...");
        vm.startBroadcast(deployerPrivateKey);
        console.log("msg.sender %s", msg.sender);

        // trigger LiquidationBot test
        LiquidationBotTest liquidationBotTest = new LiquidationBotTest();
        vm.stopBroadcast();
        console.log("vm.stopBroadcast()");

        // Prank
        console.log();
        console.log("vm.startPrank(deployer)...");
        vm.startPrank(deployer);
        console.log("msg.sender %s", msg.sender);
        vm.stopPrank();
        console.log("vm.stopPrank()");
    }
}