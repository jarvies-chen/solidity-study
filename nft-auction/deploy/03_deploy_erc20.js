module.exports = async ({ getNamedAccounts, deployments, ethers }) => {
    const { deploy } = deployments;
    const { erc20Deployer } = await getNamedAccounts();

    console.log("Deploying DAI with account:", erc20Deployer);

    const dai = await deploy("MyERC20", {
        from: erc20Deployer,
        args: ["DAI Token", "DAI", ethers.parseEther("1000000")],
        log: true,
    });

    console.log("DAI deployed to:", dai.address);
};

module.exports.tags = ["MyERC20"];
