const{ethers,upgrades} = require("hardhat");

async function main(){
    const gas = (await ethers.provider.getFeeData()).gasPrice;
    const RWAContract = await ethers.getContractFactory("RWA");
    console.log("Deploying RWA Contract ......");
    const rwaContract = await upgrades.deployProxy(RWAContract,["0x4b6428460Dc6D016f8dcD8DF2612109539DC1562"], {
        gasPrice: gas,
        initializer: "initialize",
    });

    await majorContract.waitForDeployment();
    console.log("Major Validator contract deployed to : ",await rwaContract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});