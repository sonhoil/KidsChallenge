import React from "react";
import { Coins } from "lucide-react";
import { motion } from "motion/react";

interface HeaderProps {
  points: number;
}

export function Header({ points }: HeaderProps) {
  return (
    <header className="flex items-center justify-between p-6 bg-sky-50/80 backdrop-blur-md sticky top-0 z-10">
      <div className="flex items-center gap-4">
        <motion.img 
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          src="https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080" 
          alt="Avatar" 
          className="w-14 h-14 rounded-full border-4 border-white shadow-sm object-cover" 
        />
        <div>
          <h1 className="text-xl font-extrabold text-slate-800 tracking-tight">안녕, 민수야! 👋</h1>
          <p className="text-sm text-slate-500 font-medium mt-0.5">오늘도 멋지게 시작해볼까?</p>
        </div>
      </div>
      <motion.div 
        whileHover={{ scale: 1.05 }}
        className="flex items-center gap-2 bg-amber-100 px-4 py-2.5 rounded-full border-2 border-amber-200 shadow-sm"
      >
        <Coins className="w-5 h-5 text-amber-500" />
        <span className="font-extrabold text-amber-600 text-lg">{points.toLocaleString()} P</span>
      </motion.div>
    </header>
  );
}