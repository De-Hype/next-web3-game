"use client";

import { useState } from "react";
import { Box } from "./_component/Box";
import EntriesDropDown from "./_component/EntriesDropDown";
import PrizeDropDown from "./_component/PrizeDropDown";
import type { NextPage } from "next";

// import { Address } from "~~/components/scaffold-eth";

const Home: NextPage = () => {
  const [showPrizeDropdown, setShowPrizeDropdown] = useState(false);
  const [showEntriesDropdown, setShowEntriesDropdown] = useState(false);

  const handlePrizeDropDown = () => {
    setShowPrizeDropdown(!showPrizeDropdown);
  };
  const handleEntriesDropDown = () => {
    setShowEntriesDropdown(!showEntriesDropdown);
  };

  const DailyDrawProp = {
    textHeading: "Daily Draw",
    timer: "11h 09m",
    mainTopPrize: 3.9946,
    amountInDollars: 95808.04,
    isWeekly: false,
  };

  return (
    <div
      className={`relative min-h-screen px-2 pt-2 w-full text-white bg-slate-900 md:px-1 ${
        showPrizeDropdown || showEntriesDropdown ? "overflow-y-hidden h-screen" : ""
      } `}
    >
      <div
        className={`mx-auto w-3/4 lg:w-3/4 md:px-3 pt-16 ${
          showPrizeDropdown || showEntriesDropdown ? "blur -z-50 overflow-hidden " : ""
        }`}
      >
        <LotteryHeader />
        <Box
          handlePrizeDropDown={handlePrizeDropDown}
          showPrizeDropdown={showPrizeDropdown}
          handleEntriesDropDown={handleEntriesDropDown}
          showEntriesDropdown={showEntriesDropdown}
          prop={DailyDrawProp}
        />
        {showPrizeDropdown && <PrizeDropDown handlePrizeDropDown={handlePrizeDropDown} />}
        {showEntriesDropdown && <EntriesDropDown handleEntriesDropDown={handleEntriesDropDown} />}
      </div>
    </div>
  );
};

export default Home;

const LotteryHeader = () => {
  return (
    <div className="flex items-center md:block  justify-between">
      <h3 className="font-black text-white text-7xl md:text-5xl">LOTTERY</h3>
      <button type="button" className="bg-white md:mt-6 font-bold text-sm text-black px-4 py-3 rounded-lg">
        Connect Wallet
      </button>
    </div>
  );
};
