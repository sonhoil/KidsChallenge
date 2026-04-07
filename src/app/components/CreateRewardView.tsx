import React, { useState } from "react";
import { motion } from "motion/react";
import { X, Check, Gift, Tag, Type } from "lucide-react";
import { clsx } from "clsx";

interface CreateRewardViewProps {
  onClose: () => void;
}

export function CreateRewardView({ onClose }: CreateRewardViewProps) {
  const [title, setTitle] = useState("");
  const [points, setPoints] = useState("");
  const [selectedIcon, setSelectedIcon] = useState("🎮");

  const icons = ["🎮", "💵", "🍿", "🎢", "🧸", "🚲", "📱", "🍕"];

  const handleSave = () => {
    // 실제 환경에서는 여기서 부모 컴포넌트나 상태 관리 라이브러리로 새 보상 데이터를 전달합니다.
    onClose();
  };

  return (
    <motion.div
      initial={{ y: "100%" }}
      animate={{ y: 0 }}
      exit={{ y: "100%" }}
      transition={{ type: "spring", damping: 25, stiffness: 200 }}
      className="fixed inset-0 z-50 bg-slate-50 flex flex-col"
    >
      <header className="px-5 py-4 bg-white border-b border-slate-100 shadow-sm flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <button 
            onClick={onClose}
            className="p-2 -ml-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-extrabold text-slate-800">새 보상 등록</h1>
        </div>
        <button 
          onClick={handleSave}
          disabled={!title || !points}
          className="bg-indigo-600 text-white px-4 py-2 rounded-xl font-bold text-sm disabled:opacity-50 disabled:bg-slate-300 transition-colors flex items-center gap-1.5"
        >
          <Check className="w-4 h-4 stroke-[3]" />
          저장
        </button>
      </header>

      <main className="flex-1 overflow-y-auto p-5 pb-safe flex flex-col gap-8">
        {/* Title & Icon */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <Type className="w-4 h-4" /> 보상 이름
          </label>
          <div className="flex gap-3">
            <div className="w-14 h-14 bg-white border border-slate-200 rounded-2xl flex items-center justify-center text-3xl shadow-sm shrink-0">
              {selectedIcon}
            </div>
            <input 
              type="text" 
              placeholder="예: 게임 1시간 이용권" 
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="flex-1 bg-white border border-slate-200 rounded-2xl px-4 font-bold text-slate-800 placeholder:text-slate-300 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 shadow-sm transition-all"
            />
          </div>
          <div className="flex gap-2 mt-2 overflow-x-auto pb-2 scrollbar-hide">
            {icons.map(icon => (
              <button
                key={icon}
                onClick={() => setSelectedIcon(icon)}
                className={clsx(
                  "w-10 h-10 rounded-xl flex items-center justify-center text-xl shrink-0 transition-all",
                  selectedIcon === icon 
                    ? "bg-indigo-100 border-2 border-indigo-500 scale-110" 
                    : "bg-white border border-slate-200 opacity-60 hover:opacity-100"
                )}
              >
                {icon}
              </button>
            ))}
          </div>
        </section>

        {/* Required Points */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <Tag className="w-4 h-4" /> 필요 포인트
          </label>
          <div className="relative">
            <input 
              type="number" 
              placeholder="500" 
              value={points}
              onChange={(e) => setPoints(e.target.value)}
              className="w-full bg-white border border-slate-200 rounded-2xl pl-4 pr-12 py-4 font-extrabold text-slate-800 text-lg placeholder:text-slate-300 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 shadow-sm transition-all"
            />
            <span className="absolute right-4 top-1/2 -translate-y-1/2 font-extrabold text-indigo-500">P</span>
          </div>
          <p className="text-xs text-slate-400 font-bold ml-1">
            아이들이 이 보상을 구매하기 위해 지불해야 할 포인트입니다.
          </p>
        </section>
      </main>
    </motion.div>
  );
}