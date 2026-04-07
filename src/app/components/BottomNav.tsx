import React from "react";
import { Home, ShoppingBag, User } from "lucide-react";

export function BottomNav() {
  return (
    <div className="fixed bottom-0 inset-x-0 pb-safe z-20 pointer-events-none">
      <div className="pointer-events-auto bg-white rounded-t-[2.5rem] border-t border-slate-100 p-4 pb-8 flex justify-around shadow-[0_-10px_40px_-10px_rgba(0,0,0,0.05)] max-w-md mx-auto relative overflow-hidden">
        <NavButton icon={<Home className="w-6 h-6 stroke-[2.5]" />} label="홈" active />
        <NavButton icon={<ShoppingBag className="w-6 h-6 stroke-[2.5]" />} label="상점" />
        <NavButton icon={<User className="w-6 h-6 stroke-[2.5]" />} label="프로필" />
      </div>
    </div>
  );
}

function NavButton({ icon, label, active }: { icon: React.ReactNode; label: string; active?: boolean }) {
  return (
    <button className={`flex flex-col items-center gap-1.5 transition-colors ${active ? "text-blue-500" : "text-slate-400 hover:text-slate-500"}`}>
      <div className={`p-3 rounded-2xl transition-all ${active ? "bg-blue-50/80" : "bg-transparent"}`}>
        {icon}
      </div>
      <span className="text-[11px] font-extrabold tracking-wide">{label}</span>
    </button>
  );
}