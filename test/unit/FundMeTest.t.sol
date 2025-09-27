// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe,) = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFifty() public view {
        assertEq(fundMe.MINIMUM_USD(), 50e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // <- The next line after this one should revert! We can be more specific here...
        fundMe.fund(); // <- We send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    // Can we do our withdraw function a cheaper way?
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

    function testGetConversionRate() public view {
        uint256 ethAmount = 1e18; // 1 ETH
        uint256 expectedUsd = 2000e18; // $2000 (mock price)
        uint256 actualUsd = fundMe.getConversionRate(ethAmount);
        assertEq(actualUsd, expectedUsd);
    }

    function testGetCurrentPrice() public view {
        uint256 expectedPrice = 2000e18; // Mock price with 18 decimals
        uint256 actualPrice = fundMe.getCurrentPrice();
        assertEq(actualPrice, expectedPrice);
    }

    function testGetBalance() public funded {
        uint256 balance = fundMe.getBalance();
        assertEq(balance, SEND_VALUE);
    }

    function testGetNumberOfFunders() public funded {
        uint256 numberOfFunders = fundMe.getNumberOfFunders();
        assertEq(numberOfFunders, 1);
    }

    function testGetMinimumUSD() public view {
        uint256 minimumUsd = fundMe.getMinimumUSD();
        assertEq(minimumUsd, 50e18);
    }

    function testFundingUpdatesNumberOfFunders() public {
        // Initially should be 0
        assertEq(fundMe.getNumberOfFunders(), 0);
        
        // Fund with one user
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getNumberOfFunders(), 1);
        
        // Fund with same user again (shouldn't add to array)
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getNumberOfFunders(), 1);
        
        // Fund with different user
        address USER2 = makeAddr("user2");
        vm.deal(USER2, STARTING_BALANCE);
        vm.prank(USER2);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getNumberOfFunders(), 2);
    }

    function testReceiveFunction() public {
        vm.prank(USER);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}("");
        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testFallbackFunction() public {
        vm.prank(USER);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}("0x1234");
        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }
}