import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Utils } from "alchemy-sdk";

/* Setting the base fee for the VRF coordinator. */
// const BASE_FEE = "250000000000000000"; // 0.25 is this the premium in LINK
const BASE_FEE = Utils.parseEther("0.25"); // 0.25 is this the premium in LINK
/* Setting the gas price to 0.000000001 LINK per gas. */
/* price changes based on price of gas for that blockchain */
const GAS_PRICE_LINK = 1e9;

const deploy = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  // deployer = account deploying the contract
  const { deployer } = await getNamedAccounts();
  const chainId: number = network.config.chainId!;

  if (chainId === 31337) {
    log("local network detected, deploying mock VRF  coordinator");
    await deploy("VRFCoordinatorV2Mock", {
      contract: "VRFCoordinatorV2Mock",
      from: deployer,
      log: true,
      args: [BASE_FEE, GAS_PRICE_LINK],
    });
    log("Mocks deployed");
    log("/------------------------------/");
  }
};
export default deploy;
deploy.tags = ["all", "mocks"];
