// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Get the latest ETH price in USD with 8 decimals
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Price comes with 8 decimals, we need 18 decimals to match ETH
        return uint256(price * 10**10);
    }

    // Convert ETH amount to USD equivalent
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) 
        internal 
        view 
        returns (uint256) 
    {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10**18;
        return ethAmountInUsd;
    }

    // Get version of the price feed
    function getVersion(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        return priceFeed.version();
    }
}