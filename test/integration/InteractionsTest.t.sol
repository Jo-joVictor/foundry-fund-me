// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    
    address public constant USER = address(1);
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        (fundMe,) = deploy.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        // Arrange
        uint256 preUserBalance = USER.balance;
        uint256 preOwnerBalance = fundMe.getOwner().balance;

        // Act - Fund the FundMe contract using our script
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Assert
        uint256 afterUserBalance = USER.balance;
        uint256 afterOwnerBalance = fundMe.getOwner().balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }

    function testFundFundMeContract() public {
        // Arrange
        FundFundMe fundFundMe = new FundFundMe();
        
        // Give the fundFundMe contract some ETH to spend
        vm.deal(address(fundFundMe), SEND_VALUE);
        
        uint256 preBalance = address(fundMe).balance;

        // Act
        fundFundMe.fundFundMe(address(fundMe));

        // Assert
        uint256 afterBalance = address(fundMe).balance;
        assertEq(afterBalance, preBalance + SEND_VALUE);
    }

    function testWithdrawFundMeContract() public {
        // Arrange - First fund the contract
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        
        uint256 preOwnerBalance = fundMe.getOwner().balance;
        uint256 preFundMeBalance = address(fundMe).balance;
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        // Act
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Assert
        uint256 afterOwnerBalance = fundMe.getOwner().balance;
        uint256 afterFundMeBalance = address(fundMe).balance;
        
        assertEq(afterFundMeBalance, 0);
        assertEq(afterOwnerBalance, preOwnerBalance + preFundMeBalance);
    }

    function testWithdrawFundMeWithoutFunds() public {
        // Arrange - Contract has no funds
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        uint256 preOwnerBalance = fundMe.getOwner().balance;

        // Act
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Assert - Owner balance should remain the same
        uint256 afterOwnerBalance = fundMe.getOwner().balance;
        assertEq(afterOwnerBalance, preOwnerBalance);
        assertEq(address(fundMe).balance, 0);
    }

    function testInteractionsPreserveFundMeState() public {
        // Arrange
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        
        address originalOwner = fundMe.getOwner();
        uint256 originalMinimum = fundMe.getMinimumUSD();

        // Act - Perform interactions
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // Assert - Contract state should be preserved
        assertEq(fundMe.getOwner(), originalOwner);
        assertEq(fundMe.getMinimumUSD(), originalMinimum);
        assertTrue(address(fundMe.getPriceFeed()) != address(0));
    }

    function testFundingThroughScript() public {
        // Arrange
        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(address(fundFundMe), SEND_VALUE);

        // Act
        fundFundMe.fundFundMe(address(fundMe));

        // Assert
        assertEq(address(fundMe).balance, SEND_VALUE);
        
        // The script doesn't track individual funders the same way direct calls do
        // So we just verify the balance increased
        assertTrue(address(fundMe).balance > 0);
    }
}