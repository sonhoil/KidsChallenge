import React from "react";
import { motion } from "motion/react";
import { ChevronLeft, Trophy, Star, TrendingUp, Calendar } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from "recharts";

interface ChildStatsViewProps {
  member: any;
  onBack: () => void;
}

const mockActivityData = [
  { day: "월", points: 150 },
  { day: "화", points: 200 },
  { day: "수", points: 50 },
  { day: "목", points: 300 },
  { day: "금", points: 100 },
  { day: "토", points: 400 },
  { day: "일", points: 250 },
];

const mockHistory = [
  { id: 1, type: "earn", amount: 50, reason: "방 청소하기", date: "오늘 오후 2:30" },
  { id: 2, type: "spend", amount: 100, reason: "게임 1시간 쿠폰 사용", date: "어제 오후 8:15" },
  { id: 3, type: "earn", amount: 30, reason: "숙제 완료", date: "어제 오후 5:00" },
  { id: 4, type: "earn", amount: 50, reason: "설거지 돕기", date: "3일 전" },
];

export function ChildStatsView({ member, onBack }: ChildStatsViewProps) {
  if (!member) return null;

  return (
    <motion.div 
      initial={{ x: "100%" }}
      animate={{ x: 0 }}
      exit={{ x: "100%" }}
      transition={{ type: "spring", stiffness: 400, damping: 40 }}
      className="absolute inset-0 z-40 bg-slate-50 flex flex-col"
    >
      <header className="px-4 py-4 bg-white/80 backdrop-blur-md sticky top-0 z-30 border-b border-slate-100 flex items-center gap-3 shadow-sm">
        <button 
          onClick={onBack}
          className="p-2 -ml-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100 transition-colors"
        >
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h1 className="text-xl font-extrabold text-slate-800 tracking-tight">{member.name} 활동 통계</h1>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-24 flex flex-col gap-6">
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200 flex items-center gap-4">
          <img src={member.avatarUrl} alt={member.name} className="w-16 h-16 rounded-full object-cover border-2 border-indigo-100" />
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <h2 className="font-extrabold text-xl text-slate-800">{member.name}</h2>
              <span className="bg-indigo-100 text-indigo-600 text-xs font-bold px-2 py-1 rounded-lg">LV.{member.level}</span>
            </div>
            <div className="flex items-center gap-1.5 mt-1 text-slate-500 font-medium text-sm">
              <Trophy className="w-4 h-4 text-amber-500" />
              보유 포인트: <span className="font-bold text-slate-800">{member.points.toLocaleString()} P</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200">
          <div className="flex items-center gap-2 mb-6">
            <TrendingUp className="w-5 h-5 text-indigo-500" />
            <h3 className="font-bold text-slate-800">이번 주 획득 포인트</h3>
          </div>
          <div className="h-48 w-full -ml-4">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={mockActivityData}>
                <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#94a3b8' }} dy={10} />
                <Tooltip 
                  cursor={{ fill: '#f1f5f9' }}
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  labelStyle={{ fontWeight: 'bold', color: '#1e293b' }}
                />
                <Bar dataKey="points" radius={[6, 6, 6, 6]} barSize={32}>
                  {mockActivityData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={index === mockActivityData.length - 1 ? '#6366f1' : '#cbd5e1'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200 mb-6">
          <div className="flex items-center gap-2 mb-4">
            <Calendar className="w-5 h-5 text-teal-500" />
            <h3 className="font-bold text-slate-800">최근 활동 내역</h3>
          </div>
          <div className="flex flex-col gap-4">
            {mockHistory.map((item) => (
              <div key={item.id} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-xl ${item.type === 'earn' ? 'bg-indigo-50 text-indigo-500' : 'bg-rose-50 text-rose-500'}`}>
                    {item.type === 'earn' ? <Star className="w-5 h-5" /> : <Trophy className="w-5 h-5" />}
                  </div>
                  <div>
                    <p className="font-bold text-slate-800 text-sm">{item.reason}</p>
                    <p className="text-xs text-slate-400 font-medium mt-0.5">{item.date}</p>
                  </div>
                </div>
                <span className={`font-extrabold ${item.type === 'earn' ? 'text-indigo-600' : 'text-rose-500'}`}>
                  {item.type === 'earn' ? '+' : '-'}{item.amount}P
                </span>
              </div>
            ))}
          </div>
        </div>
      </main>
    </motion.div>
  );
}