import React from "react";
import { motion } from "motion/react";
import { clsx } from "clsx";

interface CouponTabsProps {
  activeTab: "available" | "used";
  onChange: (tab: "available" | "used") => void;
  availableCount: number;
}

export function CouponTabs({ activeTab, onChange, availableCount }: CouponTabsProps) {
  return (
    <div className="flex gap-2 p-1 bg-slate-200/50 rounded-2xl mx-6 mt-4 mb-6 relative">
      <button
        onClick={() => onChange("available")}
        className={clsx(
          "flex-1 py-3 text-sm font-bold rounded-xl outline-none tap-highlight-transparent relative z-10 transition-colors flex items-center justify-center gap-2",
          activeTab === "available" ? "text-indigo-600" : "text-slate-500 hover:text-slate-700"
        )}
      >
        {activeTab === "available" && (
          <motion.div
            layoutId="coupon-tab"
            className="absolute inset-0 bg-white rounded-xl shadow-sm border border-slate-200/50"
            transition={{ type: "spring", stiffness: 400, damping: 30 }}
          />
        )}
        <span className="relative z-10">내 쿠폰</span>
        <span className="relative z-10 bg-indigo-100 text-indigo-600 px-2 py-0.5 rounded-full text-[10px] font-extrabold">
          {availableCount}
        </span>
      </button>

      <button
        onClick={() => onChange("used")}
        className={clsx(
          "flex-1 py-3 text-sm font-bold rounded-xl outline-none tap-highlight-transparent relative z-10 transition-colors",
          activeTab === "used" ? "text-slate-800" : "text-slate-500 hover:text-slate-700"
        )}
      >
        {activeTab === "used" && (
          <motion.div
            layoutId="coupon-tab"
            className="absolute inset-0 bg-white rounded-xl shadow-sm border border-slate-200/50"
            transition={{ type: "spring", stiffness: 400, damping: 30 }}
          />
        )}
        <span className="relative z-10">사용 내역</span>
      </button>
    </div>
  );
}