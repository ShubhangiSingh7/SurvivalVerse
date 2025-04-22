require("dotenv").config();
const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const abi = JSON.parse(fs.readFileSync("PlayerProgress.json", "utf8"));

  const [signer] = await hre.ethers.getSigners();
  const contract = new hre.ethers.Contract(process.env.CONTRACT_ADDRESS, abi, signer);

  const tx = await contract.updateProgress(playerAddress, finalScore, finalLevel);
  await tx.wait();

  console.log(`✅ Score ${finalScore} and level ${finalLevel} recorded on-chain!`);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
