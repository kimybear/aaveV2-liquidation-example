// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

// draft contract for liquidation call trigger mechanism

import "./balancer/IFlashLoanRecipient.sol";
import "./aave/ILendingPool.sol";


contract LiquidationBot {
    
    ILendingPool private immutable _lendingPool;

    constructor(address lendingPoolAddress) {
        _lendingPool = ILendingPool(lendingPoolAddress);
    }

    address private constant _HONEY = address(0);
    address private constant _WETH = address(0);
    address private constant _WBTC = address(0);
    address private constant _ATOKEN_WETH = address(0);
    address private constant _ATOKEN_WBTC = address(0);

    function checkHealthFactor(address user) public returns (uint256 healthFactor){
        (, , , , , uint256 healthFactor) = _lendingPool.getUserAccountData(user);
        // check health factor
        require(healthFactor < 1.0 ether, "health factor too high");
        return healthFactor;
        //triggerLiquidation(collateralAsset, debtAsset, user, debtToCover);
    }

    function triggerLiquidation (address collateralAsset,
        address debtAsset, address user, uint256 debtToCover) public {
        // determine what collateral & amount to liquidate
        // make the liquidation call

        address collateral;
        debtAsset = _HONEY;
        if (IERC20(collateralAsset).balanceOf(user) > 0) {
            collateral = collateralAsset;
        }
        if (IERC20(_ATOKEN_WBTC).balanceOf(user) > 0) {
            collateral = _WBTC;
        }
        uint256 debtToCover1 = type(uint256).max;
        approveToken(debtAsset, address(_lendingPool), debtToCover);
        _lendingPool.liquidationCall(
            collateral,
            _HONEY,
            user,
            debtToCover,
            false
        );

    }

    function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "approve failed");
    }
}