import React from "react";
import { LayoutDashboard, Users, Store, Settings, ListTodo } from "lucide-react";

interface ParentBottomNavProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
}

export function ParentBottomNav({ currentTab, onTabChange }: ParentBottomNavProps) {
  return (
    <div className="fixed bottom-0 inset-x-0 pb-safe z-20 pointer-events-none">
      <div className="pointer-events-auto bg-white border-t border-slate-100 p-3 pb-8 flex justify-around shadow-[0_-10px_40px_-10px_rgba(0,0,0,0.03)] w-full max-w-md mx-auto relative overflow-hidden">
        <NavButton 
          icon={<LayoutDashboard className="w-5 h-5 stroke-[2.5]" />} 
          label="대시보드" 
          active={currentTab === "dashboard"} 
          onClick={() => onTabChange("dashboard")}
        />
        <NavButton 
          icon={<ListTodo className="w-5 h-5 stroke-[2.5]" />} 
          label="미션" 
          active={currentTab === "missions"} 
          onClick={() => onTabChange("missions")}
        />
        <NavButton 
          icon={<Users className="w-5 h-5 stroke-[2.5]" />} 
          label="멤버" 
          active={currentTab === "members"} 
          onClick={() => onTabChange("members")}
        />
        <NavButton 
          icon={<Store className="w-5 h-5 stroke-[2.5]" />} 
          label="상점" 
          active={currentTab === "store"} 
          onClick={() => onTabChange("store")}
        />
        <NavButton 
          icon={<Settings className="w-5 h-5 stroke-[2.5]" />} 
          label="설정" 
          active={currentTab === "settings"} 
          onClick={() => onTabChange("settings")}
        />
      </div>
    </div>
  );
}

function NavButton({ icon, label, active, onClick }: { icon: React.ReactNode; label: string; active?: boolean; onClick?: () => void }) {
  return (
    <button onClick={onClick} className={`flex flex-col items-center gap-1.5 transition-colors ${active ? "text-indigo-600" : "text-slate-400 hover:text-slate-500"}`}>
      <div className={`p-2 rounded-xl transition-all ${active ? "bg-indigo-50" : "bg-transparent"}`}>
        {icon}
      </div>
      <span className="text-[10px] font-bold tracking-wide">{label}</span>
    </button>
  );
}