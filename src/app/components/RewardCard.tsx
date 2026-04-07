import React from "react";
import { Coins, Sparkles } from "lucide-react";
import { clsx } from "clsx";
import { motion } from "motion/react";

interface RewardCardProps {
  title: string;
  points: number;
  icon: React.ReactNode;
  isSpecial?: boolean;
  colorClass: string;
  onBuy: () => void;
  disabled?: boolean;
}

export function RewardCard({ title, points, icon, isSpecial, colorClass, onBuy, disabled }: RewardCardProps) {
  return (
    <motion.div 
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className="relative bg-white rounded-3xl p-4 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] border-2 border-slate-100 flex flex-col items-center gap-3 overflow-hidden"
    >
      {isSpecial && (
        <div className="absolute top-0 left-0 bg-gradient-to-r from-rose-400 to-pink-500 text-white text-[10px] font-extrabold px-3 py-1 rounded-br-2xl flex items-center gap-1 z-10 shadow-sm">
          <Sparkles className="w-3 h-3" /> SPECIAL
        </div>
      )}
      
      <div className={clsx("w-20 h-20 rounded-3xl flex items-center justify-center mb-1 mt-4 shadow-inner rotate-3", colorClass)}>
        {icon}
      </div>
      
      <div className="text-center w-full flex-1 flex flex-col justify-between">
        <h3 className="font-bold text-slate-800 text-sm leading-tight mb-2 break-keep">{title}</h3>
        <p className="text-amber-500 font-extrabold flex items-center justify-center gap-1.5 text-xs mb-3">
          <Coins className="w-3.5 h-3.5" /> {points.toLocaleString()} P
        </p>
      </div>

      <button 
        onClick={onBuy}
        disabled={disabled}
        className={clsx(
          "w-full py-2.5 rounded-xl font-bold text-sm transition-all shadow-[0_4px_0_0_rgba(0,0,0,0.1)]",
          disabled 
            ? "bg-slate-100 text-slate-400 shadow-none translate-y-1 cursor-not-allowed" 
            : "bg-indigo-500 text-white shadow-[0_4px_0_0_#3730a3] hover:bg-indigo-600 active:shadow-none active:translate-y-1"
        )}
      >
        {disabled ? "포인트 부족" : "구매하기"}
      </button>
    </motion.div>
  );
}