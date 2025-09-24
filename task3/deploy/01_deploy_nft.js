module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    
    console.log("Deploying NFT contract with account:", deployer);
    
    const nft = await deploy("NFT", {
        from: deployer,
        log: true,
        args: [],
        waitConfirmations: 1
    });
    
    console.log("NFT deployed to:", nft.address);
};

module.exports.tags = ["NFT"];