import React, { useState } from "react";
import { Gamepad2, Pizza, Ticket as TicketIcon, IceCream, Tv, Gift } from "lucide-react";
import { StoreHeader } from "./StoreHeader";
import { RewardCard } from "./RewardCard";
import confetti from "canvas-confetti";

export function StoreView({ points, onBuy }: { points: number, onBuy: (p: number) => void }) {
  const REWARDS = [
    {
      id: 1,
      title: "게임 1시간 자유이용권",
      points: 500,
      icon: <Gamepad2 className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-blue-400 to-indigo-500",
      isSpecial: true
    },
    {
      id: 2,
      title: "주말 저녁 피자 파티",
      points: 1500,
      icon: <Pizza className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-orange-400 to-rose-500",
      isSpecial: false
    },
    {
      id: 3,
      title: "놀이공원 놀러가기",
      points: 3000,
      icon: <TicketIcon className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-emerald-400 to-teal-500",
      isSpecial: true
    },
    {
      id: 4,
      title: "맛있는 아이스크림",
      points: 200,
      icon: <IceCream className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-pink-400 to-rose-400",
      isSpecial: false
    },
    {
      id: 5,
      title: "TV 시청 30분 추가",
      points: 300,
      icon: <Tv className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-violet-400 to-purple-500",
      isSpecial: false
    },
    {
      id: 6,
      title: "부모님의 깜짝 선물",
      points: 5000,
      icon: <Gift className="w-10 h-10 text-white" />,
      colorClass: "bg-gradient-to-br from-amber-400 to-yellow-500",
      isSpecial: true
    }
  ];

  return (
    <>
      <StoreHeader points={points} />
      <main className="flex-1 overflow-y-auto px-5 py-4 pb-36">
        <div className="grid grid-cols-2 gap-4">
          {REWARDS.map(reward => (
            <RewardCard 
              key={reward.id}
              title={reward.title}
              points={reward.points}
              icon={reward.icon}
              colorClass={reward.colorClass}
              isSpecial={reward.isSpecial}
              onBuy={() => onBuy(reward.points)}
              disabled={points < reward.points}
            />
          ))}
        </div>
      </main>
    </>
  );
}