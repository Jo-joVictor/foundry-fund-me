// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughETH();
error FundMe__CallFailed();

contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // State variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10**18; // $50 in wei
    AggregatorV3Interface private immutable i_priceFeed;

    // Events
    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;
        i_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /**
     * @notice Funds the contract with ETH
     * @dev Requires minimum USD equivalent amount
     */
    function fund() public payable {
        if (msg.value.getConversionRate(i_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughETH();
        }
        
        // Add to funders array only if first time funding
        if (s_addressToAmountFunded[msg.sender] == 0) {
            s_funders.push(msg.sender);
        }
        
        s_addressToAmountFunded[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    /**
     * @notice Withdraws all funds from the contract (gas expensive)
     * @dev Only owner can withdraw, resets all funders
     */
    function withdraw() public onlyOwner {
        // Reset all funders amounts
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        // Reset the funders array
        s_funders = new address[](0);
        
        // Withdraw the funds
        uint256 amount = address(this).balance;
        (bool success, ) = i_owner.call{value: amount}("");
        if (!success) revert FundMe__CallFailed();
        
        emit Withdrawn(i_owner, amount);
    }

    /**
     * @notice Cheaper withdraw using mappings (gas efficient)
     * @dev Only owner can withdraw, more gas efficient than withdraw()
     */
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        
        s_funders = new address[](0);
        
        uint256 amount = address(this).balance;
        (bool success, ) = i_owner.call{value: amount}("");
        if (!success) revert FundMe__CallFailed();
        
        emit Withdrawn(i_owner, amount);
    }

    // Getter functions
    /**
     * @notice Get amount funded by specific address
     * @param fundingAddress The address to check
     * @return The amount funded by that address
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    /**
     * @notice Get the version of the price feed
     * @return The version number
     */
    function getVersion() public view returns (uint256) {
        return i_priceFeed.version();
    }

    /**
     * @notice Get funder address by index
     * @param index The index in the funders array
     * @return The funder address at that index
     */
    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    /**
     * @notice Get the owner of the contract
     * @return The owner address
     */
    function getOwner() public view returns (address) {
        return i_owner;
    }

    /**
     * @notice Get the price feed address
     * @return The price feed contract address
     */
    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    /**
     * @notice Get the number of funders
     * @return The length of funders array
     */
    function getNumberOfFunders() public view returns (uint256) {
        return s_funders.length;
    }

    /**
     * @notice Get current ETH price in USD
     * @return The current ETH price with 18 decimals
     */
    function getCurrentPrice() public view returns (uint256) {
        return PriceConverter.getPrice(i_priceFeed);
    }

    /**
     * @notice Get USD equivalent of ETH amount
     * @param ethAmount Amount of ETH in wei
     * @return USD equivalent with 18 decimals
     */
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        return ethAmount.getConversionRate(i_priceFeed);
    }

    /**
     * @notice Get contract balance
     * @return The contract's ETH balance
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Get minimum USD funding amount
     * @return The minimum USD amount required
     */
    function getMinimumUSD() public pure returns (uint256) {
        return MINIMUM_USD;
    }

    // Fallback and receive functions
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}