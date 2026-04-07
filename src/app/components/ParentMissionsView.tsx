import React from "react";
import { motion } from "motion/react";
import { Plus, Edit2, Trash2, Calendar, Users, Target } from "lucide-react";

interface ParentMissionsViewProps {
  onOpenCreate: () => void;
}

export function ParentMissionsView({ onOpenCreate }: ParentMissionsViewProps) {
  const missions = [
    {
      id: 1,
      title: "방 청소하기",
      points: 100,
      frequency: "매일",
      assignee: "김민수",
      icon: "🧹",
      color: "bg-blue-100 text-blue-600"
    },
    {
      id: 2,
      title: "수학 문제집 3장 풀기",
      points: 150,
      frequency: "월, 수, 금",
      assignee: "김지은",
      icon: "📚",
      color: "bg-indigo-100 text-indigo-600"
    },
    {
      id: 3,
      title: "분리수거 도와주기",
      points: 200,
      frequency: "주 1회",
      assignee: "모두",
      icon: "♻️",
      color: "bg-emerald-100 text-emerald-600"
    },
    {
      id: 4,
      title: "스스로 양치질하기",
      points: 50,
      frequency: "매일",
      assignee: "모두",
      icon: "🪥",
      color: "bg-teal-100 text-teal-600"
    }
  ];

  return (
    <div className="flex flex-col h-full bg-slate-50 relative">
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 border-b border-slate-100 shadow-sm">
        <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">미션 관리</h1>
        <p className="text-sm text-slate-500 font-bold mt-1">아이들이 수행할 미션을 추가하고 수정하세요</p>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-32 flex flex-col gap-4">
        <button 
          onClick={onOpenCreate}
          className="bg-indigo-500 text-white rounded-2xl p-4 flex items-center justify-center gap-2 shadow-[0_4px_0_0_#4338ca] active:shadow-none active:translate-y-[4px] transition-all font-bold text-lg mb-2"
        >
          <Plus className="w-5 h-5 stroke-[3]" /> 새 미션 등록하기
        </button>

        <div className="flex items-center justify-between px-1 mb-1 mt-2">
          <h2 className="font-bold text-slate-700 flex items-center gap-2">
            <Target className="w-5 h-5 text-indigo-500" />
            현재 등록된 미션 <span className="text-indigo-500">{missions.length}</span>
          </h2>
        </div>

        <div className="grid grid-cols-1 gap-3">
          {missions.map((mission) => (
            <motion.div 
              key={mission.id}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200 flex flex-col gap-3"
            >
              <div className="flex items-start justify-between gap-3">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center text-2xl shrink-0 ${mission.color.split(' ')[0]}`}>
                  {mission.icon}
                </div>
                <div className="flex-1 pt-1">
                  <h3 className="font-bold text-slate-800 text-lg leading-tight">{mission.title}</h3>
                  <div className="text-amber-500 font-extrabold mt-1">+{mission.points} P</div>
                </div>
                <div className="flex flex-col gap-2 shrink-0">
                  <button className="bg-slate-100 p-2 rounded-lg text-slate-500 hover:bg-slate-200 transition-colors">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button className="bg-rose-50 p-2 rounded-lg text-rose-500 hover:bg-rose-100 transition-colors">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <div className="bg-slate-50 rounded-xl p-3 flex gap-4 mt-1 border border-slate-100">
                <div className="flex items-center gap-1.5 text-xs font-bold text-slate-500">
                  <Calendar className="w-4 h-4 text-slate-400" />
                  {mission.frequency}
                </div>
                <div className="flex items-center gap-1.5 text-xs font-bold text-slate-500">
                  <Users className="w-4 h-4 text-slate-400" />
                  대상: {mission.assignee}
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </main>
    </div>
  );
}