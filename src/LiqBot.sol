// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

interface ILendingPool {
    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external returns (uint256, uint256);

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

contract LiqBot is Ownable {
    ILendingPool private immutable lendingPool;
    address public immutable USER3;
    address public immutable USER4;

    uint256 private constant HEALTH_FACTOR_THRESHOLD = 1e18; // 1 in Aave's scale
    uint256 private constant LIQUIDATION_CLOSE_FACTOR = 0.5e18; // 50%

    mapping(address => bool) public approvedAssets;

    event LiquidationPerformed(address collateralAsset, address debtAsset, uint256 debtCovered, uint256 collateralReceived);
    event AssetApproved(address asset);

    constructor(address _lendingPool, address _user3, address _user4) {
        lendingPool = ILendingPool(_lendingPool);
        USER3 = _user3;
        USER4 = _user4;
    }
    function approveAsset(address asset) external {
        IERC20(asset).approve(address(lendingPool), type(uint256).max);
        approvedAssets[asset] = true;
        emit AssetApproved(asset);
    }

    function setAllowance(address asset, uint256 amount) external {
        require(IERC20(asset).approve(address(this), amount), "Approval failed");
    }

    function checkAndLiquidateUser4(address collateralAsset, address debtAsset) external {
        //require(msg.sender == USER3, "Only USER3 can call this function");

        (,,,,, uint256 healthFactor) = lendingPool.getUserAccountData(USER4);

        if (healthFactor < HEALTH_FACTOR_THRESHOLD) {
            _performLiquidation(collateralAsset, debtAsset);
        }
    }

    function _performLiquidation(address collateralAsset, address debtAsset) internal {
        (uint256 totalCollateralETH, uint256 totalDebtETH,,,, ) = lendingPool.getUserAccountData(USER4);

        uint256 maxDebtToCover = (totalDebtETH * LIQUIDATION_CLOSE_FACTOR) / 1e18;
        console.log("MAX Debt to cover:", maxDebtToCover);
        // Ensure USER3 has approved this contract to spend debtAsset
        uint256 largeAmount = type(uint256).max -1;
        IERC20(debtAsset).approve(address(this), largeAmount);

        // Check USER3's balance
        uint256 contractBalance = IERC20(debtAsset).balanceOf(address(this));
        console.log("contract balance", contractBalance);
        uint256 debtToCover = min(contractBalance, maxDebtToCover);
        // console.log("user3 balance", user3Balance);
        // console.log("debtToCover:", debtToCover);
        // uint256 allowance = IERC20(debtAsset).allowance(USER3, address(msg.sender));
        // console.log("Current allowance", allowance);
        // require(debtToCover > 0, "Insufficient balance for liquidation");

        //IERC20(debtAsset).approve(address(this), largeAmount);
        // Transfer debtAsset from USER3 to this contract
        //require(IERC20(debtAsset).transferFrom(USER3, address(this), debtToCover), "Transfer failed");

        // USER3 should also approve the contract to spend their tokens:
        IERC20(debtAsset).approve(address(lendingPool), type(uint256).max);
        console.log("debt to cover ", debtToCover);
        // Perform liquidation
        (uint256 liquidatedCollateralAmount, uint256 debtCovered) = lendingPool.liquidationCall(
            collateralAsset,
            debtAsset,
            USER4,
            maxDebtToCover,
            false  // receiveAToken is false, so we receive the underlying asset
        );

        // Transfer liquidated collateral to USER3
        require(IERC20(collateralAsset).transfer(USER3, liquidatedCollateralAmount), "Collateral transfer to bot failed");

        emit LiquidationPerformed(collateralAsset, debtAsset, debtCovered, liquidatedCollateralAmount);
    }

    // Function for USER3 to withdraw any remaining tokens
    function withdrawToken(address token) external {
        require(msg.sender == USER3, "Only USER3 can withdraw");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(USER3, balance);
    }

    // Allow contract to receive ETH
    receive() external payable {}

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
            return a < b ? a : b;
    }

    function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "approve failed");
    }
}