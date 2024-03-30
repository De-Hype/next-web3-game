// import { PrizesData } from "../lib/DropDownData";
import PrizeBox from "./PrizeBox";
import { AiOutlineClose } from "react-icons/ai";
import { FaEthereum } from "react-icons/fa";

const PrizeDropDown = ({ handlePrizeDropDown }) => {
  const PrizesData = [];
  return (
    <div className="absolute flex items-center overflow-hidden justify-center mx-auto w-2/5  lg:w-full md:mx-0 md:px-1 px-4 py-2 z-50 h-full top-0 right-0 left-0 bottom-0">
      <div className="bg-slate-800 h-5/6 px-5  py-3 rounded-lg ">
        <div className="flex sticky  items-center justify-between">
          <h3 className="text-white font-bold">Prizes</h3>
          <AiOutlineClose className="text-white cursor-pointer" onClick={handlePrizeDropDown} />
        </div>
        <div className="mt-8 px-2  overflow-y-auto h-[90%]">
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
            {PrizesData.map((value, index) => (
              <div
                id="bottom-border"
                className="flex items-center justify-between  py-2 px-2 border-slate-400"
                key={index}
              >
                <p className="text-slate-400 text-sm">{value.number}</p>
                <div className="flex items-center gap-1  justify-end w-1/5">
                  <h6 className="text-lime-400 text-right">{value.amountInEther}</h6>
                  <span className="bg-white px-1 py-1 rounded-full">
                    <FaEthereum className="text-right text-slate-800" />
                  </span>
                </div>
                <p className="text-slate-400 text-sm">${value.amountInDollar}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default PrizeDropDown;
