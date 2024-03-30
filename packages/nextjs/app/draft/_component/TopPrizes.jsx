// import { useState } from "react";
import PrizeBox from "./PrizeBox";
// import PrizeDropDown from "./PrizeDropDown";
import { LuMoveDiagonal } from "react-icons/lu";

const TopPrizes = ({ handlePrizeDropDown }) => {
  return (
    <div className="w-full md:w-full relative flex flex-col gap-2 px-3 py-2 h-full border rounded-md border-slate-700">
      <div className="flex justify-between items-center">
        <p className="text-slate-400 text-sm">Top Prizes</p>
        {/* <div className="bg-white h-16 w-16 right-0 top-0 absolute"></div> */}
        <div className="flex items-center gap-2">
          <p className="text-slate-400 text-sm">View All 50</p>
          <LuMoveDiagonal
            onClick={handlePrizeDropDown}
            className="text-slate-400 cursor-pointer font-extralight text-2xl self-start"
          />
        </div>
      </div>
      <PrizeBox />
    </div>
  );
};

export default TopPrizes;
