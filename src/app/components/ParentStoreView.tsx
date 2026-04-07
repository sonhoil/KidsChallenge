import React from "react";
import { motion } from "motion/react";
import { Plus, Edit2, Trash2, Tag } from "lucide-react";

interface ParentStoreViewProps {
  onOpenCreate: () => void;
}

export function ParentStoreView({ onOpenCreate }: ParentStoreViewProps) {
  const storeItems = [
    { id: 1, title: "게임 1시간 이용권", points: 500, icon: "🎮" },
    { id: 2, title: "용돈 1000원", points: 1000, icon: "💵" },
    { id: 3, title: "주말 영화 선택권", points: 2000, icon: "🍿" },
    { id: 4, title: "놀이공원 가기", points: 10000, icon: "🎢" }
  ];

  return (
    <div className="flex flex-col h-full bg-slate-50 relative">
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 border-b border-slate-100 shadow-sm">
        <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">상점 관리</h1>
        <p className="text-sm text-slate-500 font-bold mt-1">아이들이 구매할 수 있는 보상을 등록하세요</p>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-32 flex flex-col gap-4">
        <button 
          onClick={onOpenCreate}
          className="bg-indigo-500 text-white rounded-2xl p-4 flex items-center justify-center gap-2 shadow-[0_4px_0_0_#4338ca] active:shadow-none active:translate-y-[4px] transition-all font-bold text-lg mb-2"
        >
          <Plus className="w-5 h-5 stroke-[3]" /> 새 보상 등록하기
        </button>

        <div className="grid grid-cols-1 gap-3">
          {storeItems.map((item) => (
            <motion.div 
              key={item.id}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200 flex items-center gap-4"
            >
              <div className="bg-slate-100 w-12 h-12 rounded-xl flex items-center justify-center text-2xl">
                {item.icon}
              </div>
              <div className="flex-1">
                <h3 className="font-bold text-slate-800 text-base">{item.title}</h3>
                <div className="flex items-center gap-1 mt-1">
                  <Tag className="w-3 h-3 text-amber-500" />
                  <span className="text-amber-500 font-extrabold text-sm">{item.points.toLocaleString()} P</span>
                </div>
              </div>
              <div className="flex flex-col gap-2">
                <button className="bg-slate-100 p-2 rounded-lg text-slate-500 hover:bg-slate-200 transition-colors">
                  <Edit2 className="w-4 h-4" />
                </button>
                <button className="bg-rose-50 p-2 rounded-lg text-rose-500 hover:bg-rose-100 transition-colors">
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      </main>
    </div>
  );
}