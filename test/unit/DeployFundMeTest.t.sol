// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeDeployTest is Test {
    DeployFundMe deployFundMe;
    FundMe fundMe;
    HelperConfig helperConfig;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
    }

    function testDeploymentSetsCorrectOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testDeploymentSetsCorrectPriceFeed() public view {
        address priceFeedAddress = address(fundMe.getPriceFeed());
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(priceFeedAddress, expectedPriceFeed);
    }

    function testDeploymentInitializesCorrectMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 50e18);
    }

    function testDeploymentInitializesEmptyFundersArray() public view {
        assertEq(fundMe.getNumberOfFunders(), 0);
    }

    function testDeploymentInitializesZeroBalance() public view {
        assertEq(fundMe.getBalance(), 0);
    }

    function testPriceFeedIsWorking() public view {
        uint256 price = fundMe.getCurrentPrice();
        assertTrue(price > 0);
    }

    function testConversionRateIsWorking() public view {
        uint256 ethAmount = 1e18; // 1 ETH
        uint256 conversionRate = fundMe.getConversionRate(ethAmount);
        assertTrue(conversionRate > 0);
    }

    function testHelperConfigReturnsCorrectNetworkConfig() public view {
        address networkConfig = helperConfig.activeNetworkConfig();
        assertTrue(networkConfig != address(0));
    }

    function testDeploymentCanBeCalledMultipleTimes() public {
        // Deploy another instance
        DeployFundMe secondDeployment = new DeployFundMe();
        (FundMe secondFundMe, HelperConfig secondHelperConfig) = secondDeployment.run();
        
        // Both should be valid but different instances
        assertTrue(address(secondFundMe) != address(fundMe));
        assertEq(secondFundMe.getOwner(), msg.sender);
        assertEq(address(secondFundMe.getPriceFeed()), secondHelperConfig.activeNetworkConfig());
    }

    function testDeployedContractMatchesExpectedInterface() public view {
        // Test that deployed contract has all expected functions
        // These calls should not revert
        fundMe.getOwner();
        fundMe.getPriceFeed();
        fundMe.getBalance();
        fundMe.getNumberOfFunders();
        fundMe.getCurrentPrice();
        fundMe.getMinimumUSD();
    }
}