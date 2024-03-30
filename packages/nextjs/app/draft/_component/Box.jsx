import { useEffect, useState } from "react";
// import react from "../assets/BuidlGuidlLogo";
//Could change to main image
import react from "../assets/react.svg";
import EnterDraw from "./EnterDraw";
import TopPrizes from "./TopPrizes";
import { FaAngleDown, FaAngleUp } from "react-icons/fa";

export const Box = ({ prop, handlePrizeDropDown, showPrizeDropdown, handleEntriesDropDown, showEntriesDropdown }) => {
  const [show, setShow] = useState(false);
  let [convertAmountInDollars, setConvertAmountInDollars] = useState(prop.amountInDollars);
  let [convertMainTopPrize, setConvertMainTopPrize] = useState(prop.mainTopPrize);
  const [countDown, setCountDown] = useState({ months: 0, days: 0 });
  const handleShow = () => {
    setShow(!show);
  };
  const IncrementValue = () => {
    setConvertMainTopPrize((prop.mainTopPrize -= 0.001));

    setConvertAmountInDollars(prop.amountInDollars++);
  };
  const calculateCountDown = () => {
    const days = 256;
    const months = Math.floor(days / 30);
    const remainingDays = days % 30;
    setCountDown({ months, days: remainingDays });
  };

  useEffect(() => {
    calculateCountDown();
    setInterval(() => {
      IncrementValue();
      calculateCountDown();
    }, 20000);

    return () => {
      clearInterval();
    };
  }, []);

  return (
    <div className="flex relative flex-col gap-3 mt-4 bg-indigo-900 px-3 py-2 rounded-[12px]">
            <div className="flex items-center justify-between">
        <h4
          className={` font-bold ${
            prop.isWeekly ? "text-green-300" : "text-lime-400"
          }`}
        >
          {prop?.textHeading}
        </h4>
        
        <div className="text-white bg-black flex items-center gap-2 py-1 px-2 rounded-lg">
          <h4 className="">
            {countDown.months} <span className="text-sm text-slate-500">d</span>
          </h4>
          <h4 className="">
            {countDown.days} <span className="text-sm text-slate-500">m</span>
          </h4>
        </div>
      </div>
      <div
        className={`${show ? "h-1/3" : "h-full"}  -z-50  w-1/5 right-0 top-0 absolute ${
          prop.isWeekly ? "radial-lime" : "radial-green"
        }`}
      >

      </div>
      <div
        onClick={handleShow}
        className="flex items-center px-2  rounded-lg justify-between cursor-pointer glass-background-show transition-all"
      >
        <div className="flex items-center gap-2">
          <img src={react} alt="alt" />
          <div className="">
            <p className="text-slate-400 text-sm">Prize Pool (ETH)</p>
            <h3 className={`font-black text-4xl  ${prop.isWeekly ? "text-green-300" : "text-lime-400"}`}>
              {convertMainTopPrize.toFixed(3)}
            </h3>
            <p className="text-slate-400 text-sm">${convertAmountInDollars.toLocaleString()}</p>
          </div>
        </div>
        <div className="px-4 py-4 rounded-xl  glass-background ">
          {show ? (
            <FaAngleUp className="text-slate-300 font-bold" />
          ) : (
            <FaAngleDown className="text-slate-300 font-bold" />
          )}
        </div>
      </div>

{show && (
          <div
            className={` gap-2  flex md:flex-col md:w-full top-full left-0 w-full add-animation-dropdown h-full transition-all`}
          >
            <EnterDraw
              handleEntriesDropDown={handleEntriesDropDown}
              showEntriesDropdown={showEntriesDropdown}
            />
            <TopPrizes
              handlePrizeDropDown={handlePrizeDropDown}
              showPrizeDropdown={showPrizeDropdown}
            />
          </div>
        )}
    </div>
  );
};
