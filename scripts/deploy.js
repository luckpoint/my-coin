const hre = require("hardhat");

async function main() {
  // Get the contract factory for MyToken
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  // Deploy MyToken
  // MyToken constructor: constructor(string memory name, string memory symbol, uint256 initialSupplyToOwner)
  const myTokenName = "MyUserCoin";
  const myTokenSymbol = "MUC";
  const initialSupply = hre.ethers.parseUnits("1000000", 18); // Assuming 18 decimals for initial supply calculation

  console.log(`Deploying MyToken with name=${myTokenName}, symbol=${myTokenSymbol}, initialSupply=${hre.ethers.formatUnits(initialSupply, 18)} tokens (raw: ${initialSupply.toString()})...`);
  const myToken = await MyToken.deploy(myTokenName, myTokenSymbol, initialSupply);
  // Wait for the deployment to complete
  await myToken.waitForDeployment();
  console.log(`MyToken deployed to: ${myToken.target}`);

  // Get the contract factory for Shop
  const Shop = await hre.ethers.getContractFactory("Shop");
  // Deploy Shop, passing the MyToken contract address to its constructor
  const shop = await Shop.deploy(myToken.target);
  // Wait for the deployment to complete
  await shop.waitForDeployment();
  console.log(`Shop deployed to: ${shop.target}`);

  console.log("\nDeployment successful!");
  console.log("MyToken address:", myToken.target);
  console.log("Shop address:", shop.target);
}

// We recommend this pattern to be ableable to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 