// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Auction.sol";

contract AuctionFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address[] public auctions;  // 存储所有拍卖合约地址
    address public priceOracle;         // 价格预言机合约地址
    address public auctionImplementation; // 拍卖合约实现地址

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _auctionImplementation, address _priceOracle) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        require(_auctionImplementation != address(0), "Invalid auction implementation");
        require(_priceOracle != address(0), "Invalid price oracle");

        auctionImplementation = _auctionImplementation;
        priceOracle = _priceOracle;
    }

    /**
     * 创建新的拍卖合约
     */
    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        address _seller,
        uint256 _startTime,
        uint256 _endTime
    ) external returns (address) {
        require(_nftContract != address(0), "Invalid NFT contract");
        require(_endTime > _startTime, "End time must be after start time");
        
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender, "Not owner of NFT");
        
        address auction = Clones.clone(auctionImplementation);
        
        Auction(payable(auction)).initialize(
            _nftContract,
            _tokenId,
            _seller,
            _startTime,
            _endTime,
            priceOracle
        );
        
        IERC721(_nftContract).transferFrom(msg.sender, auction, _tokenId);
        
        auctions.push(auction);
        return auction;
    }

    /**
     * 获取所有拍卖合约地址
     */
    function getAuctions() external view returns (address[] memory) {
        return auctions;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
