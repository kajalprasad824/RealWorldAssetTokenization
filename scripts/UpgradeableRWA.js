const { ethers, upgrades } = require("hardhat");

const UPGRADEABLE_PROXY = "0x8D38dAc6e5b854a8699d2d428755577E4e338A91";

async function main() {
   const gas = (await ethers.provider.getFeeData()).gasPrice;
   const upgradeableRWA = await ethers.getContractFactory("RWA");
   console.log("Upgrading V1Contract...");
   let upgrade = await upgrades.upgradeProxy(UPGRADEABLE_PROXY, upgradeableRWA, {
      gasPrice: gas
   });
   console.log("V1 Upgraded to V2");
   console.log("Upgraded Contract Deployed To:", await upgrade.getAddress())
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });