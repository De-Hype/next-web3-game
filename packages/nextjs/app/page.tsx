"use client";

// import { useState } from "react";
// import { Box } from "../components/raffle/Box";
import { Utils } from "alchemy-sdk";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
// import EntriesDropDown from "~~/components/raffle/EntriesDropDown";
// import PrizeDropDown from "~~/components/raffle/PrizeDropDown";
// import { Address } from "~~/components/scaffold-eth";
import { useDeployedContractInfo, useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const Home: NextPage = () => {
  const input = Utils.parseEther("0.01");

  const { address: connectedAddress } = useAccount();

  const { data: raffle } = useDeployedContractInfo("Raffle");

  const { data: rafflePoolBalance } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "getBalance",
  });

  const { data: recentWinners } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "getRecentWinners",
  });

  // const { data: s_players } = useScaffoldContractRead({
  //   contractName: "Raffle",
  //   functionName: "s_players",
  //   args: [],
  // });

  const { data: raffleState } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "getRaffleState",
  });

  const { data: hasUsedFreeEntry } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "hasUsedFreeEntry",
    args: [connectedAddress],
  });

  const { data: getSpecialWallets } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "getSpecialWallets",
    args: [connectedAddress] as [bigint | undefined],
  });

  const { data: winnings } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "winnings",
    args: [connectedAddress],
  });

  const { data: treasuryAmount } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "treasuryAmount",
  });

  // get unique value
  const { data: getNumberOfPlayers } = useScaffoldContractRead({
    contractName: "Raffle",
    functionName: "getNumberOfPlayers",
  });
  // ----------------------------------------------------------------------//
  // ------------------------WRITE------------------------------------------//
  // ----------------------------------------------------------------------//
  const { writeAsync: enterRaffle } = useScaffoldContractWrite({
    contractName: "Raffle",
    functionName: "enterRaffle",
    // @ts-ignore
    args: [input],
  });

  const { writeAsync: claimWinnings } = useScaffoldContractWrite({
    contractName: "Raffle",
    functionName: "claimWinnings",
  });

  const { writeAsync: claimTreasury } = useScaffoldContractWrite({
    contractName: "Raffle",
    functionName: "claimTreasury",
  });

  const { writeAsync: performUpkeep } = useScaffoldContractWrite({
    contractName: "Raffle",
    functionName: "performUpkeep",
    args: ["0x"],
  });

  console.log(raffle?.abi);

  return (
    <div className={`relative min-h-screen px-2 pt-2 w-full text-white bg-slate-900 md:px-1  `}>
      <div className={`mx-auto w-3/4 lg:w-3/4 md:px-3 pt-16 `}>
        <h1>READ</h1>
        <h3>winnings: {winnings?.toString()}</h3>
        <h3>specialWallets: {getSpecialWallets?.toString()}</h3>
        <h3>treasuryAmount: {treasuryAmount?.toString()}</h3>
        <h3>rafflePoolBalance: {rafflePoolBalance?.toString()}</h3>
        <h3>recentWinners: {recentWinners}</h3>
        <h3>getNumberOfPlayers: {getNumberOfPlayers?.toString()}</h3>
        <h3>raffleState: {raffleState}</h3>
        <h3 className="pb-6">hasUsedFreeEntry: {hasUsedFreeEntry}</h3>
        <h1>WRITE</h1>
        <button className="btn" onClick={() => claimWinnings()}>
          claimWinnings
        </button>
        <br />
        <br />

        <button className="btn" onClick={() => claimTreasury()}>
          claimTreasury
        </button>
        <br />
        <br />
        <input type="text" />
        <button className="btn" onClick={() => enterRaffle()}>
          enterRaffle
        </button>
        <br />
        <br />
        <button className="btn" onClick={() => performUpkeep()}>
          performUpkeep
        </button>
      </div>
    </div>
  );
};

export default Home;
