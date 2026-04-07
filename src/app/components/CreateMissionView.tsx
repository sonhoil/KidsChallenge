import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Check, Target, Gift, Users, Calendar } from "lucide-react";
import { clsx } from "clsx";

interface CreateMissionViewProps {
  onClose: () => void;
}

export function CreateMissionView({ onClose }: CreateMissionViewProps) {
  const [title, setTitle] = useState("");
  const [points, setPoints] = useState("");
  const [assignee, setAssignee] = useState("all");
  const [frequency, setFrequency] = useState("daily");
  const [selectedIcon, setSelectedIcon] = useState("🧹");
  const [selectedDays, setSelectedDays] = useState<string[]>([]);

  const icons = ["🧹", "📚", "♻️", "🪥", "🛏️", "🍽️", "🐕", "💪"];
  const assignees = [
    { id: "all", label: "모두" },
    { id: "minsu", label: "김민수" },
    { id: "jieun", label: "김지은" },
  ];
  const frequencies = [
    { id: "daily", label: "매일" },
    { id: "custom_days", label: "요일 지정" },
    { id: "weekly_1", label: "주 1회" },
    { id: "weekend", label: "주말만" },
  ];

  const daysOfWeek = [
    { id: "mon", label: "월" },
    { id: "tue", label: "화" },
    { id: "wed", label: "수" },
    { id: "thu", label: "목" },
    { id: "fri", label: "금" },
    { id: "sat", label: "토" },
    { id: "sun", label: "일" },
  ];

  const toggleDay = (dayId: string) => {
    setSelectedDays(prev => 
      prev.includes(dayId) 
        ? prev.filter(d => d !== dayId)
        : [...prev, dayId]
    );
  };

  const handleSave = () => {
    // 실제 환경에서는 여기서 부모 컴포넌트나 상태 관리 라이브러리로 새 미션 데이터를 전달합니다.
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
          <h1 className="text-xl font-extrabold text-slate-800">새 미션 등록</h1>
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
            <Target className="w-4 h-4" /> 미션 이름
          </label>
          <div className="flex gap-3">
            <div className="w-14 h-14 bg-white border border-slate-200 rounded-2xl flex items-center justify-center text-3xl shadow-sm shrink-0">
              {selectedIcon}
            </div>
            <input 
              type="text" 
              placeholder="예: 내 방 청소하기" 
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

        {/* Points */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <Gift className="w-4 h-4" /> 보상 포인트
          </label>
          <div className="relative">
            <input 
              type="number" 
              placeholder="100" 
              value={points}
              onChange={(e) => setPoints(e.target.value)}
              className="w-full bg-white border border-slate-200 rounded-2xl pl-4 pr-12 py-4 font-extrabold text-slate-800 text-lg placeholder:text-slate-300 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 shadow-sm transition-all"
            />
            <span className="absolute right-4 top-1/2 -translate-y-1/2 font-extrabold text-indigo-500">P</span>
          </div>
        </section>

        {/* Assignee */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <Users className="w-4 h-4" /> 수행 대상
          </label>
          <div className="flex gap-2">
            {assignees.map(item => (
              <button
                key={item.id}
                onClick={() => setAssignee(item.id)}
                className={clsx(
                  "flex-1 py-3 rounded-2xl font-bold text-sm transition-all border shadow-sm",
                  assignee === item.id 
                    ? "bg-indigo-50 border-indigo-500 text-indigo-700" 
                    : "bg-white border-slate-200 text-slate-500 hover:bg-slate-50"
                )}
              >
                {item.label}
              </button>
            ))}
          </div>
        </section>

        {/* Frequency */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <Calendar className="w-4 h-4" /> 반복 주기
          </label>
          <div className="grid grid-cols-2 gap-2">
            {frequencies.map(item => (
              <button
                key={item.id}
                onClick={() => setFrequency(item.id)}
                className={clsx(
                  "py-3 rounded-2xl font-bold text-sm transition-all border shadow-sm",
                  frequency === item.id 
                    ? "bg-indigo-50 border-indigo-500 text-indigo-700" 
                    : "bg-white border-slate-200 text-slate-500 hover:bg-slate-50"
                )}
              >
                {item.label}
              </button>
            ))}
          </div>

          {/* Custom Days Selection */}
          <AnimatePresence>
            {frequency === "custom_days" && (
              <motion.div 
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden"
              >
                <div className="flex justify-between gap-1.5 pt-2">
                  {daysOfWeek.map(day => {
                    const isSelected = selectedDays.includes(day.id);
                    const isWeekend = day.id === "sat" || day.id === "sun";
                    return (
                      <button
                        key={day.id}
                        onClick={() => toggleDay(day.id)}
                        className={clsx(
                          "flex-1 aspect-square rounded-full flex items-center justify-center font-bold text-sm transition-all border",
                          isSelected
                            ? "bg-indigo-500 border-indigo-500 text-white shadow-sm"
                            : "bg-white border-slate-200 hover:bg-slate-50",
                          !isSelected && isWeekend ? "text-rose-500" : !isSelected ? "text-slate-500" : ""
                        )}
                      >
                        {day.label}
                      </button>
                    );
                  })}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </section>
      </main>
    </motion.div>
  );
}