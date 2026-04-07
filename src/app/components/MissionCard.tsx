import React from "react";
import { motion } from "motion/react";
import { Check, Clock } from "lucide-react";
import { clsx } from "clsx";

interface MissionCardProps {
  title: string;
  points: number;
  icon: React.ReactNode;
  onComplete: () => void;
  status: 'todo' | 'pending' | 'approved';
}

export function MissionCard({ title, points, icon, onComplete, status }: MissionCardProps) {
  const isCompleted = status === 'approved';
  const isPending = status === 'pending';

  return (
    <motion.div 
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={clsx(
        "bg-white p-5 rounded-[2rem] flex items-center gap-4 border-2 shadow-sm transition-all duration-300",
        isCompleted ? "border-slate-100 bg-slate-50/50" : isPending ? "border-amber-100 bg-amber-50/30" : "border-transparent"
      )}
    >
      <div className={clsx(
        "p-4 rounded-[1.25rem] flex-shrink-0 transition-colors duration-300", 
        isCompleted ? "bg-slate-200 text-slate-400" : isPending ? "bg-amber-100 text-amber-500" : "bg-blue-100 text-blue-500"
      )}>
        {icon}
      </div>
      
      <div className="flex-grow">
        <h3 className={clsx(
          "font-bold text-lg mb-1 transition-all duration-300", 
          isCompleted ? "text-slate-400 line-through" : isPending ? "text-slate-700" : "text-slate-800"
        )}>
          {title}
        </h3>
        <p className={clsx(
          "font-extrabold flex items-center gap-1 text-sm transition-all duration-300",
          isCompleted ? "text-slate-400" : isPending ? "text-amber-500" : "text-amber-500"
        )}>
          +{points} P
        </p>
      </div>

      <button 
        onClick={onComplete}
        disabled={status !== 'todo'}
        className={clsx(
          "px-4 py-3 rounded-[1.25rem] font-bold text-sm transition-all flex items-center justify-center min-w-[5rem] gap-1.5",
          isCompleted 
            ? "bg-slate-200 text-slate-500 cursor-not-allowed" 
            : isPending
              ? "bg-amber-100 text-amber-600 cursor-not-allowed border-2 border-amber-200"
              : "bg-emerald-400 text-white shadow-[0_4px_0_0_#059669] hover:bg-emerald-500 hover:shadow-[0_4px_0_0_#047857] active:shadow-none active:translate-y-1"
        )}
      >
        {isCompleted ? (
          <><Check className="w-4 h-4 stroke-[3]" /> 지급됨</>
        ) : isPending ? (
          <><Clock className="w-4 h-4 stroke-[3]" /> 승인 대기</>
        ) : (
          "완료하기"
        )}
      </button>
    </motion.div>
  );
}