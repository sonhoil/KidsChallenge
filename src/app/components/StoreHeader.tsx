import React from "react";
import { Coins } from "lucide-react";

export function StoreHeader({ points }: { points: number }) {
  return (
    <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 flex items-center justify-between border-b border-slate-100 shadow-sm">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">쿠폰 상점 🎁</h1>
        <p className="text-sm text-slate-500 font-bold mt-1">포인트를 보상으로 교환해봐요!</p>
      </div>
      <div className="flex items-center gap-2 bg-amber-50 px-4 py-2.5 rounded-full border border-amber-200 shadow-sm">
        <Coins className="w-5 h-5 text-amber-500" />
        <span className="font-extrabold text-amber-600 text-lg">{points.toLocaleString()}</span>
      </div>
    </header>
  );
}