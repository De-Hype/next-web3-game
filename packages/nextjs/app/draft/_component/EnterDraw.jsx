// import { useState } from "react";
import { LuMoveDiagonal } from "react-icons/lu";

const EnterDraw = ({ handleEntriesDropDown }) => {
  // const [input, setInput] = useState(null);

  return (
    <div className="flex h-full flex-col gap-3 w-full md:w-full">
      <div className="bg-black px-3 py-2 flex flex-col gap-4 rounded-md">
        <div className="flex items-center justify-between">
          <h4 className="text-white font-semibold">Enter Draw</h4>
          <div className="flex items-center gap-3">
            <p className="text-slate-400 text-sm">Your Tickets</p>
            <h4 className="text-white font-bold">0</h4>
            {/* Icon */}
          </div>
        </div>
        <div className="flex items-center w-full  gap-4 ">
          <div className="flex items-center w-full border border-slate-700 rounded-md px-3  gap-2">
            <button className="text-white font-bold" type="button">
              -
            </button>
            <input
              type="text"
              name=""
              min={0}
              max={1}
              className="bg-slate-700  h-10 px-4 w-full text-white text-center outline-none font-semibold"
              id=""
              defaultValue={1}
              onChange={() => console.log(e.target, value)}
              // onChange={() => setInput(e.target, value)}
            />
            <button className="text-white font-bold" type="button">
              +
            </button>
          </div>
          <h4 className="border border-slate-700 text-white font-semibold rounded-md px-3 py-2">Max</h4>
        </div>
        <button type="button" className="bg-white w-full font-bold text-sm px-4 py-3 rounded-lg">
          Connect Wallet
        </button>
      </div>
      <div className="flex items-center justify-between px-3 py-2  border border-slate-700 rounded-md">
        <div className="">
          <p className="text-slate-400 text-sm">Your Entries</p>
          <h3 className="text-white font-bold text-lg  ">0</h3>
          <p className="text-slate-400 text-sm">Rank -</p>
        </div>
        <div className="">
          <p className="text-slate-400 text-sm">Total Entries</p>
          <h3 className="text-white font-bold text-lg ">78,589</h3>
          <p className="text-slate-400 text-sm">684 players</p>
        </div>
        <LuMoveDiagonal
          onClick={handleEntriesDropDown}
          className="text-slate-400 cursor-pointer font-semibold text-2xl self-start"
        />
      </div>
    </div>
  );
};

export default EnterDraw;
