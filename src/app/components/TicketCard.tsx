import React from "react";
import { motion } from "motion/react";
import { clsx } from "clsx";

interface TicketCardProps {
  id: string;
  title: string;
  ownerName: string;
  avatarUrl: string;
  isUsed: boolean;
  dateStr: string;
  onUse?: (id: string) => void;
}

export function TicketCard({ id, title, ownerName, avatarUrl, isUsed, dateStr, onUse }: TicketCardProps) {
  return (
    <motion.div 
      layout
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.9 }}
      className={clsx(
        "relative flex w-full rounded-2xl shadow-sm border overflow-hidden transition-all duration-300",
        isUsed ? "bg-slate-50 border-slate-200 opacity-75 grayscale-[0.5]" : "bg-white border-indigo-100 shadow-[0_4px_20px_-4px_rgba(79,70,229,0.15)]"
      )}
    >
      {/* Background Pattern for "Ticket" feel */}
      <div className="absolute inset-0 opacity-[0.03] pointer-events-none" style={{ backgroundImage: 'radial-gradient(circle at 2px 2px, black 1px, transparent 0)', backgroundSize: '16px 16px' }} />

      {/* Main Content (Left) */}
      <div className="flex-1 p-5 flex flex-col justify-center gap-3 relative z-10">
        <div className="flex items-center gap-2">
          <img src={avatarUrl} alt={ownerName} className="w-6 h-6 rounded-full border border-slate-200 object-cover" />
          <span className="text-xs font-bold text-slate-500">{ownerName}의 쿠폰</span>
        </div>
        <div>
          <h3 className={clsx("font-extrabold text-lg leading-tight break-keep", isUsed ? "text-slate-600" : "text-slate-800")}>
            {title}
          </h3>
          <p className="text-xs font-semibold text-slate-400 mt-1">{dateStr}</p>
        </div>
      </div>

      {/* Perforated Divider & Cutouts (Matching parent bg #F8FAFC) */}
      <div className="relative w-0 flex flex-col justify-center border-l-[3px] border-dashed border-slate-200">
        {/* Top Notch */}
        <div className="absolute -top-1 -left-3 w-6 h-4 bg-[#F8FAFC] rounded-b-full border-b border-x border-slate-200/50" />
        {/* Bottom Notch */}
        <div className="absolute -bottom-1 -left-3 w-6 h-4 bg-[#F8FAFC] rounded-t-full border-t border-x border-slate-200/50" />
      </div>

      {/* Action Area (Right) */}
      <div className={clsx(
        "w-28 flex flex-col items-center justify-center p-4 relative z-10",
        isUsed ? "bg-slate-100" : "bg-indigo-50/50"
      )}>
        {isUsed ? (
          <div className="transform -rotate-12 border-[3px] border-rose-400 text-rose-500 font-black text-sm px-3 py-1 rounded-lg opacity-80 shadow-sm">
            사용완료
          </div>
        ) : (
          <button 
            onClick={() => onUse?.(id)}
            className="w-full py-3 rounded-xl bg-indigo-500 text-white font-extrabold text-sm shadow-[0_4px_0_0_#3730a3] hover:bg-indigo-600 active:shadow-none active:translate-y-1 transition-all flex flex-col items-center gap-1"
          >
            <span>지금 사용</span>
          </button>
        )}
      </div>
    </motion.div>
  );
}