// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceOracle {
    mapping(address => AggregatorV3Interface) public priceFeeds;
    
    // 模拟价格存储（用于测试）
    mapping(uint256 => uint256) public testEthPrices;
    mapping(address => uint256) public testTokenPrices;

    constructor(address ethUsdFeed) {
        // 使用 address(0) 代表 ETH/USD 价格预言机
        priceFeeds[address(0)] = AggregatorV3Interface(ethUsdFeed); // 使用 address(0) 代表 ETH/USD 价格预言机
    }

    /**
     * 设置某个代币的价格预言机地址
     */
    function setPriceFeed(address token, address feed) external {
        priceFeeds[token] = AggregatorV3Interface(feed);
    }

    /**
     * 获取某个代币的最新价格
     */
    function getLatestPrice(address token) external view returns (int256) {
        AggregatorV3Interface priceFeed = priceFeeds[token];
        require(address(priceFeed) != address(0), "Price feed not set for this token");
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * 获取 ETH/USD 的最新价格
    */
    function getEthUsdPrice() external view returns (int256) {
        AggregatorV3Interface priceFeed = priceFeeds[address(0)];
        require(address(priceFeed) != address(0), "Price feed not set for ETH");
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * 将某个代币的数量转换为 USD 价值
     */
    function convertToUSD(address token, uint256 amount) external view returns (uint256) {
        if (token == address(0)) {
            // ETH 直接返回 USD 价值
            int256 ethPrice = this.getEthUsdPrice();
            require(ethPrice > 0, "Invalid ETH price");
            return (amount * uint256(ethPrice)) / 1e8; // 假设价格有8位小数
        } else {
            // 其他代币需要先获取其价格
            int256 price = this.getLatestPrice(token);
            require(price > 0, "Invalid price");
            return (amount * uint256(price)) / 1e8; // 假设价格有8位小数
        }
    }

    /**
     * @dev 设置测试价格（仅用于测试环境）
     */
    function setTestPrice(address token, uint256 price) external {
        if (token == address(0)) {
            testEthPrices[block.chainid] = price;
        } else {
            testTokenPrices[token] = price;
        }
    }
}