const{ethers,upgrades} = require("hardhat");

async function main(){
    const gas = (await ethers.provider.getFeeData()).gasPrice;
    const RWAContract = await ethers.getContractFactory("RWA");
    console.log("Deploying RWA Contract ......");
    const rwaContract = await upgrades.deployProxy(RWAContract,["0x4b6428460Dc6D016f8dcD8DF2612109539DC1562"], {
        gasPrice: gas,
        initializer: "initialize",
    });

    await rwaContract.waitForDeployment();
    console.log("RWA contract deployed to : ",await rwaContract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
//0x8D38dAc6e5b854a8699d2d428755577E4e338A91.
//0x2dd55F9c8bE4186B2BEb1F691cE45F40c21c5911