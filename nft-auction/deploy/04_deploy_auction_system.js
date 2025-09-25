module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { auctionDeployer } = await getNamedAccounts();

    console.log("Deploying Auction System with account:", auctionDeployer);

    // 获取已部署的依赖合约
    const nftDeployment = await deployments.get("NFT");
    const oracleDeployment = await deployments.get("PriceOracle");

    console.log("NFT deployed at:", nftDeployment.address);
    console.log("PriceOracle deployed at:", oracleDeployment.address);

    // 1. 部署拍卖实现合约
    console.log("Deploying Auction implementation...", auctionDeployer);

    const auctionImpl = await deploy("Auction", {
        from: auctionDeployer,
        args: [],
        log: true
     });
    console.log("Auction implementation deployed to:", auctionImpl.address);

    // 2. 使用 upgrades.deployProxy 部署工厂合约
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    console.log("Deploying AuctionFactory with proxy...");
    
    const factory = await upgrades.deployProxy(AuctionFactory, [
        auctionImpl.address,
        oracleDeployment.address
    ], {
        initializer: 'initialize',
        kind: 'uups'
    });
    console.log("AuctionFactory deployed to:", factory.target);
};

module.exports.tags = ["AuctionSystem"];
module.exports.dependencies = ["NFT", "PriceOracle", "MyERC20"];