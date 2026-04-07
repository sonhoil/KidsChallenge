import React from "react";
import { Check, X, Clock } from "lucide-react";
import { motion } from "motion/react";

interface PendingCardProps {
  id: number;
  kidName: string;
  avatarUrl: string;
  taskName: string;
  points: number;
  timeAgo: string;
  onApprove: (id: number) => void;
  onReject: (id: number) => void;
}

export function PendingCard({ id, kidName, avatarUrl, taskName, points, timeAgo, onApprove, onReject }: PendingCardProps) {
  return (
    <motion.div 
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9, transition: { duration: 0.2 } }}
      layout
      className="bg-white rounded-2xl p-4 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] border border-slate-100 flex flex-col gap-4"
    >
      <div className="flex items-center gap-3">
        <img src={avatarUrl} alt={kidName} className="w-12 h-12 rounded-full object-cover border-2 border-slate-50" />
        <div className="flex-1">
          <p className="text-sm font-semibold text-slate-500 flex items-center gap-1.5">
            {kidName} 
            <span className="text-slate-300">•</span> 
            <span className="text-xs text-slate-400 flex items-center gap-1"><Clock className="w-3 h-3" /> {timeAgo}</span>
          </p>
          <h3 className="font-bold text-slate-800 text-lg leading-tight mt-0.5">{taskName}</h3>
        </div>
        <div className="bg-amber-100 text-amber-600 font-extrabold px-3 py-1.5 rounded-xl text-sm">
          +{points} P
        </div>
      </div>

      <div className="flex gap-2 w-full pt-1">
        <button 
          onClick={() => onReject(id)}
          className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-slate-100 text-slate-600 font-bold text-sm hover:bg-rose-50 hover:text-rose-500 transition-colors"
        >
          <X className="w-4 h-4" /> 반려
        </button>
        <button 
          onClick={() => onApprove(id)}
          className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-emerald-500 text-white font-bold text-sm hover:bg-emerald-600 shadow-[0_3px_0_0_#047857] active:shadow-none active:translate-y-[3px] transition-all"
        >
          <Check className="w-4 h-4 stroke-[3]" /> 승인하기
        </button>
      </div>
    </motion.div>
  );
}