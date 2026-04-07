import React, { useState } from "react";
import { motion } from "motion/react";
import { 
  User, 
  Settings, 
  Bell, 
  ShieldCheck, 
  ChevronRight, 
  Trophy, 
  Star,
  LogOut
} from "lucide-react";
import { clsx } from "clsx";

interface ProfileViewProps {
  points: number;
  onSwitchToParentMode?: () => void;
}

export function ProfileView({ points, onSwitchToParentMode }: ProfileViewProps) {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  const menuItems = [
    { id: "parent", icon: <ShieldCheck className="w-5 h-5 text-indigo-500" />, label: "부모님 모드 전환", color: "bg-indigo-100" },
    { id: "account", icon: <User className="w-5 h-5 text-blue-500" />, label: "내 정보 수정", color: "bg-blue-100" },
    { id: "settings", icon: <Settings className="w-5 h-5 text-slate-500" />, label: "앱 설정", color: "bg-slate-200" },
  ];

  return (
    <>
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 flex items-center gap-3 border-b border-slate-100 shadow-sm">
        <div className="bg-sky-100 p-2.5 rounded-xl">
          <User className="w-6 h-6 text-sky-600" />
        </div>
        <div>
          <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">내 프로필</h1>
          <p className="text-sm text-slate-500 font-bold mt-0.5">나의 멋진 기록을 확인해봐!</p>
        </div>
      </header>

      <main className="flex-1 overflow-y-auto px-6 py-6 pb-36 flex flex-col gap-6">
        
        {/* Profile Card */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-[2rem] p-6 shadow-sm border-2 border-slate-100/50 flex flex-col items-center text-center relative overflow-hidden"
        >
          <div className="absolute top-0 inset-x-0 h-24 bg-gradient-to-br from-sky-400 to-indigo-500 opacity-20" />
          
          <div className="relative z-10">
            <div className="relative">
              <img 
                src="https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080" 
                alt="Profile Avatar" 
                className="w-24 h-24 rounded-full border-4 border-white shadow-md object-cover relative z-10" 
              />
              <div className="absolute -bottom-2 -right-2 bg-amber-400 text-white p-1.5 rounded-full border-2 border-white shadow-sm z-20">
                <Star className="w-5 h-5 fill-white" />
              </div>
            </div>
            
            <h2 className="text-2xl font-extrabold text-slate-800 mt-4">김민수</h2>
            <p className="text-sm font-bold text-indigo-500 mt-1">LV.3 도움 요정 🧚</p>
          </div>

          <div className="w-full bg-slate-100 rounded-full h-3 mt-5 overflow-hidden">
            <motion.div 
              initial={{ width: 0 }}
              animate={{ width: "65%" }}
              transition={{ duration: 1, delay: 0.2 }}
              className="bg-indigo-500 h-full rounded-full"
            />
          </div>
          <p className="text-xs font-semibold text-slate-400 mt-2 w-full text-right">다음 레벨까지 350P</p>
        </motion.div>

        {/* Stats Grid */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="grid grid-cols-2 gap-4"
        >
          <div className="bg-white rounded-[1.5rem] p-5 shadow-sm border-2 border-slate-100/50 flex flex-col items-center justify-center gap-2">
            <div className="bg-amber-100 p-3 rounded-2xl text-amber-500">
              <Trophy className="w-7 h-7" />
            </div>
            <div className="text-center">
              <p className="text-xs font-bold text-slate-400">완료한 미션</p>
              <p className="text-xl font-extrabold text-slate-800">42개</p>
            </div>
          </div>
          <div className="bg-white rounded-[1.5rem] p-5 shadow-sm border-2 border-slate-100/50 flex flex-col items-center justify-center gap-2">
            <div className="bg-emerald-100 p-3 rounded-2xl text-emerald-500">
              <Star className="w-7 h-7" />
            </div>
            <div className="text-center">
              <p className="text-xs font-bold text-slate-400">보유 포인트</p>
              <p className="text-xl font-extrabold text-slate-800">{points.toLocaleString()}P</p>
            </div>
          </div>
        </motion.div>

        {/* Menu List */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-white rounded-[2rem] shadow-sm border-2 border-slate-100/50 overflow-hidden"
        >
          {/* Toggle Menu Item */}
          <div className="flex items-center justify-between p-5 border-b border-slate-100">
            <div className="flex items-center gap-4">
              <div className="p-2.5 rounded-xl bg-rose-100">
                <Bell className="w-5 h-5 text-rose-500" />
              </div>
              <span className="font-bold text-slate-700">푸시 알림</span>
            </div>
            <button 
              onClick={() => setNotificationsEnabled(!notificationsEnabled)}
              className={clsx(
                "w-12 h-7 rounded-full transition-colors relative",
                notificationsEnabled ? "bg-indigo-500" : "bg-slate-200"
              )}
            >
              <motion.div 
                layout
                className="w-5 h-5 bg-white rounded-full shadow-sm absolute top-1"
                animate={{ left: notificationsEnabled ? "24px" : "4px" }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
              />
            </button>
          </div>

          {/* Regular Menu Items */}
          {menuItems.map((item, index) => (
            <button 
              key={item.id}
              onClick={item.id === "parent" ? onSwitchToParentMode : undefined}
              className={clsx(
                "w-full flex items-center justify-between p-5 transition-colors hover:bg-slate-50 active:bg-slate-100 text-left",
                index !== menuItems.length - 1 && "border-b border-slate-100"
              )}
            >
              <div className="flex items-center gap-4">
                <div className={clsx("p-2.5 rounded-xl", item.color)}>
                  {item.icon}
                </div>
                <span className="font-bold text-slate-700">{item.label}</span>
              </div>
              <ChevronRight className="w-5 h-5 text-slate-300" />
            </button>
          ))}
        </motion.div>

      </main>
    </>
  );
}