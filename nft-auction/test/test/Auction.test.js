const {expect} = require("chai");
const {ethers, upgrades} = require("hardhat");

describe("Auction Contract", function () {
    let nftDeployer, oracleDeployer, erc20Deployer, auctionDeployer, bidder1, bidder2;
    let nft, oracle, dai, factory;
    beforeEach(async function () {
        [nftDeployer, oracleDeployer, erc20Deployer, auctionDeployer, bidder1, bidder2] = await ethers.getSigners();

        // Deploy NFT contract
        const NFTFactory = await ethers.getContractFactory("NFT", nftDeployer);
        nft = await NFTFactory.deploy(nftDeployer.address);

        console.log("NFT deployed to:", nft.target);

        // Deploy Price Oracle contract
        const OracleFactory = await ethers.getContractFactory("PriceOracle", oracleDeployer);
        oracle = await OracleFactory.deploy("0x694AA1769357215DE4FAC081bf1f309aDC325306");
        
        console.log("PriceOracle deployed to:", oracle.target);

        // Set test prices in the oracle
        oracle.setTestPrice(ethers.ZeroAddress, ethers.parseEther("3000")); // Set test price for ETH/USD 1 ETH = 3000 USD

        const ERC20Factory = await ethers.getContractFactory("MyERC20", erc20Deployer);
        dai = await ERC20Factory.deploy("DAI", "DAI", ethers.parseEther("1000000"));

        console.log("DAI deployed to:", dai.target);

        await oracle.setTestPrice(dai.target, ethers.parseEther("1")); // Set test price for DAI/USD 1 DAI = 1 USD

        // Deploy Auction contract
        const AuctionContractFactory = await ethers.getContractFactory("Auction", auctionDeployer);
        const  auctionImpl = await AuctionContractFactory.deploy();
        
        console.log("Auction implementation deployed to:", auctionImpl.target);

        // Deploy Auction Factory
        const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
        factory = await upgrades.deployProxy(AuctionFactory, 
            [auctionImpl.target, oracle.target], 
            {initializer: 'initialize'}
        );

        // Mint an NFT to auctionDeployer
        await nft.connect(nftDeployer).mintNFT(nftDeployer.address, "https://example.com/nft1");

        // Approve the factory to transfer the NFT
        await nft.connect(nftDeployer).approve(factory.target, 1);
        // Create an auction    
        const tx = await factory.connect(nftDeployer).createAuction(
            nft.target,
            1,
            nftDeployer.address,
            Math.floor(Date.now() / 1000) - 60,  // Start time in the past
            Math.floor(Date.now() / 1000) + 3600
        );
        const receipt = await tx.wait();
        // Get the auction address from the factory's auctions array
        const auctions = await factory.getAuctions();
        const auctionAddress = auctions[auctions.length - 1];
        auction = await ethers.getContractAt("Auction", auctionAddress);
    });

    describe("ETH Bid Tests", function () {
        it("Should accept valid ETH bids", async function () {
            const bidAmount = ethers.parseEther("0.05"); // 0.05 ETH = 150 USD
            const tx = await auction.connect(bidder1).placeBid(
                ethers.ZeroAddress, 
                bidAmount,
                { value: bidAmount }    // Send ETH
            );
            // Check highest bid
            let highestBid = await auction.getHighestBid();
            expect(highestBid.amount).to.equal(ethers.parseEther("0.05"));

            await auction.connect(bidder2).placeBid(
                ethers.ZeroAddress, 
                ethers.parseEther("0.06"), // 0.06 ETH = 180 USD
                { value: ethers.parseEther("0.06") }
            );
            // Check highest bid
            highestBid = await auction.getHighestBid();
            expect(highestBid.amount).to.equal(ethers.parseEther("0.06"));
        });
    });

    describe("ERC20 Bid Tests", function () {
        it("Should accept USDT bid", async function () {
            // 授权合约转移 DAI
            await dai.connect(erc20Deployer).approve(auction.target, ethers.parseEther("150"));

            // 使用 DAI 出价
            await auction.connect(erc20Deployer).placeBid(
                dai.target,
                ethers.parseEther("150")
            );
            
            // 验证出价成功
            const highestBid = await auction.getHighestBid();
            expect(highestBid.bidder).to.equal(erc20Deployer.address);
            expect(highestBid.amount).to.equal(ethers.parseEther("150"));
            expect(highestBid.token).to.equal(dai.target);
        });
    
    });
});
