// import { ethers, getNamedAccounts, network } from "hardhat";
// import { assert, expect } from "chai";
// import { Raffle } from "../typechain-types";
// // import "hardhat/console.sol";
// // import networkConfig from "../helper-hardhat-config";

// /**
//  * before staging test is done
//  * Get the subId from chainlink VRF and fund the subscriptioon
//  * deploy using subId
//  * register contract with chainlink vrf & subId
//  * register contract with chainlink keepers
//  * rub staging tests
//  */

// /** */
// const chainId = network.config.chainId;
// chainId === 31337
//   ? describe.skip
//   : describe("lottery Staging Tests", () => {
//       /* Defining a variable called raffle of type Raffle. */
//       let raffle: Raffle;
//       /* Defining a variable called deployer of type string. */
//       let deployer: string;
//       /* Defining a variable called vrfCoordinatorV2Mock of type VRFConsumerBaseV2. */
//       let entranceFee: string;

//       beforeEach(async () => {
//         /* Assigning the deployer variable to the deployer account. */
//         deployer = (await getNamedAccounts()).deployer;
//         /* Assigning the raffle variable to the Raffle contract. */
//         raffle = await ethers.getContract("Raffle", deployer);
//         entranceFee = (await raffle.getEntranceFee()).toString();
//       });

//       describe("fulfillRandomWords", function () {
//         it("works with live Chainlink Keepers and Chainlink VRF, we get a random winner", async function () {
//           // enter the raffle
//           console.log("Setting up test...");

//           const startingTimeStamp = await raffle.getLastTimeStamp();
//           const accounts = await ethers.getSigners();

//           console.log("Setting up Listener...");
//           await new Promise<void>(async (resolve, reject) => {
//             // setup listener before we enter the raffle
//             // Just in case the blockchain moves REALLY fast
//             raffle.once("FirstWinnerPicked", async () => {
//               console.log("WinnerPicked event fired!");

//               try {
//                 // add our asserts here
//                 /* Getting the recent winner of the raffle. */
//                 const recentWinner = await raffle.getRecentWinner();
//                 console.log("recentWinner", recentWinner);
//                 /* Getting the state of the raffle. */
//                 const raffleState = await raffle.getRaffleState();
//                 /* Getting the balance of the first account in the accounts array. (the deployer account) */
//                 const winnerEndingBalance = await accounts[0].getBalance();
//                 /* Getting the last timestamp of the raffle. */
//                 const endingTimeStamp = await raffle.getLastTimeStamp();
//                 /* Checking that the player at index 0 is reverted. */
//                 await expect(raffle.getPlayer(0)).to.be.reverted;
//                 /* Checking that the recent winner is the same as the first account in the accounts
//                 array. (given the first account is the winner ) */
//                 assert.equal(recentWinner.toString(), accounts[0].address);
//                 /* Checking that the raffle state is 0. */
//                 assert.equal(raffleState, 0);
//                 /* Checking that the winner's balance is equal to the winner's starting balance plus
//                 the entrance fee. */
//                 // assert.equal(
//                 //   winnerEndingBalance.toString(),
//                 //   winnerStartingBalance.add(entranceFee).toString()
//                 // );
//                 console.log(winnerEndingBalance.toString(), winnerStartingBalance.add(entranceFee).toString());
//                 /* It's checking that the timestamp has changed. */
//                 assert(endingTimeStamp > startingTimeStamp);
//                 resolve();
//               } catch (error) {
//                 console.log(error);
//                 reject(error);
//               }
//             });
//             // Then entering the raffle
//             console.log("Entering Raffle...");
//             /* It's calling the enterRaffle function of the raffle contract. */
//             const tx = await raffle.enterRaffle({
//               value: entranceFee,
//             });
//             /* It's waiting for the transaction to be mined. */
//             await tx.wait(1);
//             console.log("Ok, time to wait...");
//             const winnerStartingBalance = await accounts[0].getBalance();
//             // and this code WONT complete until our listener has finished listening!
//           });
//         });
//       });
//     });
