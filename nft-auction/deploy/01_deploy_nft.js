module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments;
    const { nftDeployer } = await getNamedAccounts();
    
    console.log("Deploying NFT contract with account:", nftDeployer);
    
    const nft = await deploy("NFT", {
        from: nftDeployer,
        log: true,
        args: [nftDeployer],
        waitConfirmations: 1
    });
    
    console.log("NFT deployed to:", nft.address);
};

module.exports.tags = ["NFT"];