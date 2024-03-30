import PrizeBox from "./PrizeBox";
import { AiOutlineClose } from "react-icons/ai";

const EntriesDropDown = ({ handleEntriesDropDown }) => {
  const EntriesData = [];
  return (
    <div className="absolute flex items-center overflow-hidden justify-center mx-auto w-2/5  lg:w-full md:mx-0 md:px-1 px-4 py-2 z-50 h-full top-0 right-0 left-0 bottom-0">
      <div className="bg-slate-800 h-5/6 px-5  py-3 rounded-lg ">
        <div className="flex sticky  items-center justify-between">
          <h3 className="text-white font-bold">Prizes</h3>
          <AiOutlineClose className="text-white cursor-pointer" onClick={handleEntriesDropDown} />
        </div>
        <div className="mt-8 px-2 overflow-x-hidden overflow-y-auto h-[90%]">
          <h6 className="text-white font-medium ">
            Prizes are randomly allocated to players, in order of largest prize to smallest. The number of lottery
            tickets you enter respresents your possibility of wining a prize.
          </h6>
          <p className="text-slate-400 my-2 text-sm">
            You can only win one prize per lottery draw, and if there are fewer than 50 winners, any remaining prize
            funds are returned to the treasury.
          </p>
          <PrizeBox />
          <div className="mt-2 border border-slate-400 glass rounded-md">
            <div id="bottom-border" className="flex items-center justify-between  py-2 px-2 border-slate-400">
              <div className="flex w-1/5 items-center justify-between">
                <p className="text-slate-400 text-sm">#</p>
                <p className="text-slate-400 text-sm">Player</p>
              </div>
              <p className="text-slate-400 text-sm">Entries</p>
            </div>
            {EntriesData.map((value, index) => (
              <div
                id="bottom-border"
                className="flex items-center justify-between  py-2 px-2 border-slate-400"
                key={index}
              >
                <div className="flex items-center  justify-between   w-2/5">
                  <p className="text-slate-400 text-sm">{value.number}</p>
                  <div className="flex items-center self-start  w-3/4 gap-2">
                    <img src={""} className="h-6 w-6 rounded-full" alt="" />
                    <p className="text-slate-400 text-sm">{value.username}</p>
                  </div>
                </div>
                <p className="text-slate-400 text-sm">{value.entries.toLocaleString()}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default EntriesDropDown;
