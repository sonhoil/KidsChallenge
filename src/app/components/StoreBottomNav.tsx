import React from "react";
import { Home, ShoppingBag, Ticket, User } from "lucide-react";
import { clsx } from "clsx";

interface StoreBottomNavProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
}

export function StoreBottomNav({ currentTab, onTabChange }: StoreBottomNavProps) {
  return (
    <div className="fixed bottom-0 inset-x-0 pb-safe z-20 pointer-events-none">
      <div className="pointer-events-auto bg-white rounded-t-[2.5rem] border-t border-slate-100 p-4 pb-8 flex justify-around shadow-[0_-10px_40px_-10px_rgba(0,0,0,0.05)] max-w-md mx-auto relative overflow-hidden">
        <NavButton 
          icon={<Home className="w-6 h-6 stroke-[2.5]" />} 
          label="홈" 
          active={currentTab === "home"}
          onClick={() => onTabChange("home")}
        />
        <NavButton 
          icon={<ShoppingBag className="w-6 h-6 stroke-[2.5]" />} 
          label="상점" 
          active={currentTab === "store"}
          onClick={() => onTabChange("store")}
        />
        <NavButton 
          icon={<Ticket className="w-6 h-6 stroke-[2.5]" />} 
          label="내 쿠폰" 
          active={currentTab === "coupons"}
          onClick={() => onTabChange("coupons")}
        />
        <NavButton 
          icon={<User className="w-6 h-6 stroke-[2.5]" />} 
          label="프로필" 
          active={currentTab === "profile"}
          onClick={() => onTabChange("profile")}
        />
      </div>
    </div>
  );
}

function NavButton({ icon, label, active, onClick }: { icon: React.ReactNode; label: string; active?: boolean; onClick: () => void }) {
  return (
    <button 
      onClick={onClick}
      className={clsx("flex flex-col items-center gap-1.5 transition-colors", active ? "text-indigo-600" : "text-slate-400 hover:text-slate-500")}
    >
      <div className={clsx("p-3 rounded-2xl transition-all", active ? "bg-indigo-50/80" : "bg-transparent")}>
        {icon}
      </div>
      <span className="text-[11px] font-extrabold tracking-wide">{label}</span>
    </button>
  );
}