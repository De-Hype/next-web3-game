import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, Address } from "hardhat-deploy/dist/types";
import networkConfig from "../helper-hardhat-config";
import { Utils } from "alchemy-sdk";

// const vrfSubscriptionFundAmount = Utils.parseEther("2");

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  // deployer = account deploying the contract (comes from hardhat.config.namedAccounts)
  const { deployer } = await getNamedAccounts();

  console.log(`deployer`, deployer);

  const chainId: number = network.config.chainId!;

  let VRFCoordinatorv2Address: Address | string | undefined;
  let subscriptionId: string | undefined;

  if (chainId !== 31337) {
    VRFCoordinatorv2Address = networkConfig[chainId].vrfCoordinatorv2;
    subscriptionId = networkConfig[chainId].subscriptionId;
  }

  const entranceFee: string = Utils.parseEther("0.01").toString(); // include fee;
  const keyHash: string = networkConfig[chainId].keyHash;
  const callBackGasLimit: string = networkConfig[chainId].callBackGasLimit;
  const treasury = "0xb3757a0808Dc4b4Ae05386245d058ff6cFe1Ce31"; // << deployer

  const args = [VRFCoordinatorv2Address, entranceFee, keyHash, subscriptionId, callBackGasLimit, treasury];

  const raffle = await deploy("Raffle", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: 1,
  });

  log(`Raffle deployed at ${raffle.address}`);
  log("/------------------------------------------/");
};

export default deploy;
deploy.tags = ["all", "raffle"];
