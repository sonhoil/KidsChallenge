import React, { useState } from "react";
import { Ticket as TicketIcon } from "lucide-react";
import { AnimatePresence } from "motion/react";
import confetti from "canvas-confetti";
import { CouponTabs } from "./CouponTabs";
import { TicketCard } from "./TicketCard";

interface Coupon {
  id: string;
  title: string;
  ownerName: string;
  avatarUrl: string;
  dateStr: string;
  isUsed: boolean;
}

const INITIAL_COUPONS: Coupon[] = [
  {
    id: "c1",
    title: "게임 1시간 자유이용권 🎮",
    ownerName: "민수",
    avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
    dateStr: "오늘 구매함",
    isUsed: false
  },
  {
    id: "c2",
    title: "맛있는 아이스크림 🍦",
    ownerName: "민수",
    avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
    dateStr: "어제 구매함",
    isUsed: false
  },
  {
    id: "c3",
    title: "놀이공원 놀러가기 🎡",
    ownerName: "민수",
    avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
    dateStr: "3일 전 구매함",
    isUsed: true
  },
  {
    id: "c4",
    title: "주말 저녁 피자 파티 🍕",
    ownerName: "민수",
    avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
    dateStr: "1주일 전 구매함",
    isUsed: true
  }
];

export function CouponView() {
  const [coupons, setCoupons] = useState<Coupon[]>(INITIAL_COUPONS);
  const [activeTab, setActiveTab] = useState<"available" | "used">("available");

  const handleUse = (id: string) => {
    confetti({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
      colors: ['#4f46e5', '#3b82f6', '#fcd34d', '#10b981'],
      disableForReducedMotion: true
    });

    setCoupons(prev => 
      prev.map(c => c.id === id ? { ...c, isUsed: true, dateStr: "방금 사용함" } : c)
    );
  };

  const availableCoupons = coupons.filter(c => !c.isUsed);
  const usedCoupons = coupons.filter(c => c.isUsed);
  const displayCoupons = activeTab === "available" ? availableCoupons : usedCoupons;

  return (
    <>
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 flex items-center gap-3 border-b border-slate-100 shadow-sm">
        <div className="bg-indigo-100 p-2.5 rounded-xl">
          <TicketIcon className="w-6 h-6 text-indigo-600" />
        </div>
        <div>
          <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">쿠폰함</h1>
          <p className="text-sm text-slate-500 font-bold mt-0.5">보상으로 받은 쿠폰을 확인하세요!</p>
        </div>
      </header>
      
      <main className="flex-1 overflow-y-auto pb-36">
        <CouponTabs 
          activeTab={activeTab} 
          onChange={setActiveTab} 
          availableCount={availableCoupons.length} 
        />
        
        <div className="px-6 flex flex-col gap-4">
          <AnimatePresence mode="popLayout">
            {displayCoupons.length > 0 ? (
              displayCoupons.map((coupon) => (
                <TicketCard 
                  key={coupon.id}
                  {...coupon}
                  onUse={handleUse}
                />
              ))
            ) : (
              <div className="flex flex-col items-center justify-center py-20 text-center">
                <TicketIcon className="w-16 h-16 text-slate-200 mb-4" />
                <h3 className="text-lg font-bold text-slate-600">
                  {activeTab === "available" ? "아직 사용할 수 있는 쿠폰이 없어요!" : "아직 사용한 쿠폰이 없어요!"}
                </h3>
                <p className="text-slate-400 mt-2 text-sm font-medium">상점에서 미션 포인트로 쿠폰을 구매해보세요.</p>
              </div>
            )}
          </AnimatePresence>
        </div>
      </main>
    </>
  );
}