module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    console.log("Deploying PriceOracle contract with account:", deployer);

    const oracle = await deploy("PriceOracle", {
        from: deployer,
        args: ["0x694AA1769357215DE4FAC081bf1f309aDC325306"], // Example: Chainlink ETH/USD price feed on Ethereum mainnet
        log: true,
    });

    console.log("PriceOracle contract deployed at address:", oracle.address);
};

module.exports.tags = ["PriceOracle"];