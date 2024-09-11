// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

/// @title LuckyDraw
/// @author BlockCMD
/// @notice A price converter library that convert tokens on KLAYTN network to USD amount using Pyth Network
library PriceConverterPyth {
    /// @notice Fetch the price of KLAY in USD from Pyth Network price feed
    /// @param priceFeed The address of the price feed contract
    /// @return price The KLAY/USD exchange rate in 18 digit
    function getPrice(bytes32 feedId, IPyth priceFeed, bytes[] calldata priceUpdate) internal returns (uint256 price) {
        // Submit a priceUpdate to the Pyth contract to update the on-chain price.
        // Updating the price requires paying the fee returned by getUpdateFee.
        // WARNING: These lines are required to ensure the getPrice call below succeeds. If you remove them,
        // transactions may fail with "0x19abf40e" error.
        IPyth pyth = priceFeed;
        uint fee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{ value: fee }(priceUpdate);

        // Read the current price from a price feed.
        // Each price feed (e.g., ETH/USD) is identified by a price feed ID.
        // The complete list of feed IDs is available at https://pyth.network/developers/price-feed-ids
        // bytes32 priceFeedId = 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743; // KLAY/USD
        PythStructs.Price memory NewPrice = pyth.getPrice(feedId);
        // PythStructs.Price memory NewPrice = pyth.getPriceUnsafe(feedId);
        price =  (uint256(uint64(NewPrice.price) * 10 ** 10));
    }

    /// @notice Convert the any token on the KLAYTN network to USD amount
    /// @param klayAmount The amount of KLAY to convert
    /// @param priceFeed The address of the price feed contract
    /// @return klayAmountInUsd The amount of KLAY in USD
    function getConversionRate(uint256 klayAmount, bytes32 feedId, IPyth priceFeed, bytes[] calldata priceUpdate) internal returns (uint256 klayAmountInUsd) {
        uint256 klayPrice = getPrice(feedId, priceFeed, priceUpdate);
        klayAmountInUsd = (klayPrice * klayAmount) / 1e18;
    }

    /** Get the latest price and confidence interval for the requested price feed id. The price feed id is a 32-byte id written as a hexadecimal string; see the price feed ids page to look up the id for a given symbol. The returned price and confidence are decimal numbers written in the form a * 10^e, where e is an exponent included in the result. For example, a price of 1234 with an exponent of -2 represents the number 12.34. The result also includes a publishTime which is the unix timestamp for the price update. */ 
    function getUnsafePrice(bytes32 feedId, IPyth priceFeed) internal view returns (uint256 price) {
        IPyth pyth = priceFeed;
        PythStructs.Price memory NewPrice = pyth.getPriceUnsafe(feedId);
        price =  (uint256(uint64(NewPrice.price) * 10 ** 10));
    }


    /** Get the latest price and confidence interval for the requested price feed id. The price feed id is a 32-byte id written as a hexadecimal string; see the price feed ids page to look up the id for a given symbol. The returned price and confidence are decimal numbers written in the form a * 10^e, where e is an exponent included in the result. For example, a price of 1234 with an exponent of -2 represents the number 12.34. The result also includes a publishTime which is the unix timestamp for the price update. */ 
    function getConversionRateUnsafe(uint256 klayAmount, bytes32 feedId, IPyth priceFeed) internal view returns (uint256 klayAmountInUsd) {
        uint256 klayPrice = getUnsafePrice(feedId, priceFeed);
        klayAmountInUsd = (klayPrice * klayAmount) / 1e18;
    }
}
