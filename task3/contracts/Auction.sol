// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PriceOracle.sol";

contract Auction is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    struct AuctionItem {
        // 拍卖基本信息字段
        address nftContract;     // NFT 合约地址
        uint256 tokenId;         // NFT 代币 ID
        address seller;          // 卖家地址
        uint256 startTime;       // 拍卖开始时间
        uint256 endTime;         // 拍卖结束时间
        bool ended;              // 拍卖是否结束
    }

    struct Bid {
        // 出价信息字段
        address bidder;          // 出价人地址
        address token;           // 出价使用的代币地址 (ddress(0) for ETH)
        uint256 amount;          // 出价金额(美元价值)
        uint256 timestamp;       // 出价时间戳
    }

    Bid public highestBid;              // 当前最高出价
    AuctionItem public auctionItem;     // 当前拍卖项目信息
    PriceOracle public priceOracle;     // 价格预言机合约地址

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * 初始化拍卖合约
     */
    function initialize(
        address _nftContract,
        uint256 _tokenId,
        address _seller,
        uint256 _startTime,
        uint256 _endTime,
        address _priceOracle) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        // 初始化拍卖合约状态
        require(_nftContract != address(0), "Invalid NFT contract address");
        require(_seller != address(0), "Invalid seller address");
        require(_startTime >= block.timestamp, "Start time must be in the future");
        require(_endTime > _startTime, "End time must be after start time");
        require(_priceOracle != address(0), "Invalid price oracle address");

        auctionItem = AuctionItem({
            nftContract: _nftContract,
            tokenId: _tokenId,
            seller: _seller,
            startTime: _startTime,
            endTime: _endTime,
            ended: false
        }); 
        priceOracle = PriceOracle(_priceOracle);
    }

    /**
     * 出价函数，支持以太坊和 ERC20 代币出价
     */
    function placeBid(address _token, uint256 _amount) external payable {
        require(block.timestamp >= auctionItem.startTime, "Auction not started yet");
        require(block.timestamp <= auctionItem.endTime, "Auction already ended");
        require(!auctionItem.ended, "Auction has ended");
        require(_amount > 0, "Bid amount must be greater than zero");

        // 竞拍逻辑
        uint256 usdAmount;
        if (_token == address(0)) {
            // 以太坊出价逻辑
            require(msg.value == _amount, "ETH amount mismatch");
            usdAmount = priceOracle.convertToUSD(address(0), _amount);
        } else {
            // ERC20 代币出价逻辑
            require(msg.value == 0, "ETH not accepted for ERC20 bids");
            IERC20(_token).transferFrom(msg.sender, address(this), _amount);
            usdAmount = priceOracle.convertToUSD(_token, _amount);
        }
        // 检查是否高于当前最高出价 (按美元价值比较)
        uint256 currentHighestUSD = 0;
        if (highestBid.amount > 0) {
            currentHighestUSD = priceOracle.convertToUSD(highestBid.token, highestBid.amount);
        }
        require(usdAmount > currentHighestUSD, "Bid must be higher than current highest bid");

        // 退还之前最高出价
        if (highestBid.bidder != address(0)) {
            if (highestBid.token == address(0)) {
                // 退还 ETH
                payable(highestBid.bidder).transfer(highestBid.amount);
            } else {
                //退还 ERC20 代币
                IERC20(highestBid.token).transfer(highestBid.bidder, highestBid.amount);
            }
        }

        // 更新最高出价
        highestBid = Bid({
            bidder: msg.sender,
            token: _token,
            amount: _amount,
            timestamp: block.timestamp
        });
    }

    /**
     * 结束拍卖
     */
    function endAuction() external {
        require(!auctionItem.ended, "Auction already ended");
        require(block.timestamp >= auctionItem.endTime || (block.timestamp >= auctionItem.startTime && highestBid.amount > 0), 
                "Auction not ended yet");   
        auctionItem.ended = true;
        // 处理拍卖结果
        if (highestBid.bidder != address(0)) {
            // 转移 NFT 给最高出价者
            IERC721(auctionItem.nftContract).transferFrom(address(this), highestBid.bidder, auctionItem.tokenId);
            // 将出价金额转给卖家
            if (highestBid.token == address(0)) {
                payable(auctionItem.seller).transfer(highestBid.amount);
            } else {
                IERC20(highestBid.token).transfer(auctionItem.seller, highestBid.amount);
            }
        } else {
            // 无人出价，NFT 归还给卖家
            IERC721(auctionItem.nftContract).transferFrom(address(this), auctionItem.seller, auctionItem.tokenId);
        }
    }

    /**
     * 获取最高出价
     */
    function getHighestBid() external view returns (Bid memory) {
        return highestBid;
    }

    /**
     * 获取拍卖项目信息
     */
    function getAuctionItem() external view returns (AuctionItem memory) {
        return auctionItem;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    // 接受以太坊转账
    receive() external payable {}
}   