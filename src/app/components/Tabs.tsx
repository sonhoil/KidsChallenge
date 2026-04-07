import React from "react";
import { motion } from "motion/react";

interface TabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

const tabs = ["매일", "주간", "특별"];

export function Tabs({ activeTab, onTabChange }: TabsProps) {
  return (
    <div className="flex gap-2 px-6 mb-6 mt-2">
      {tabs.map((tab) => (
        <button
          key={tab}
          onClick={() => onTabChange(tab)}
          className="relative px-6 py-3 rounded-full font-bold text-base outline-none tap-highlight-transparent flex-1"
        >
          {activeTab === tab ? (
            <motion.div
              layoutId="active-tab"
              className="absolute inset-0 bg-blue-500 rounded-full shadow-md"
              transition={{ type: "spring", stiffness: 400, damping: 30 }}
            />
          ) : null}
          <span className={`relative z-10 block ${activeTab === tab ? "text-white" : "text-slate-400"}`}>
            {tab}
          </span>
        </button>
      ))}
    </div>
  );
}