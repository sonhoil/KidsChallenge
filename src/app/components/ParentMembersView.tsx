import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Plus, User, MoreVertical, Trophy, Link as LinkIcon } from "lucide-react";
import { ShareLinkModal } from "./ShareLinkModal";
import { ChildStatsView } from "./ChildStatsView";
import { PointAdjustmentModal } from "./PointAdjustmentModal";

interface ParentMembersViewProps {
  onOpenCreate: () => void;
}

export function ParentMembersView({ onOpenCreate }: ParentMembersViewProps) {
  const [shareLinkData, setShareLinkData] = useState<{ isOpen: boolean; memberName: string; link: string } | null>(null);
  const [statsChild, setStatsChild] = useState<any>(null);
  const [pointModalChild, setPointModalChild] = useState<any>(null);

  const members = [
    {
      id: 1,
      name: "김민수",
      level: 3,
      points: 1500,
      avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080"
    },
    {
      id: 2,
      name: "김지은",
      level: 2,
      points: 850,
      avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080"
    }
  ];

  return (
    <div className="flex flex-col h-full bg-slate-50 relative">
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 border-b border-slate-100 shadow-sm">
        <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">아이 관리</h1>
        <p className="text-sm text-slate-500 font-bold mt-1">우리 아이들의 활동을 확인하세요</p>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-32 flex flex-col gap-4">
        {members.map((member) => (
          <motion.div 
            key={member.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl p-5 shadow-sm border border-slate-200 flex flex-col gap-4"
          >
            <div className="flex justify-between items-start">
              <div className="flex items-center gap-4">
                <img src={member.avatarUrl} alt={member.name} className="w-14 h-14 rounded-full object-cover border-2 border-slate-100" />
                <div>
                  <h3 className="font-bold text-lg text-slate-800">{member.name}</h3>
                  <span className="text-indigo-500 text-sm font-bold">LV.{member.level}</span>
                </div>
              </div>
              <button 
                onClick={() => setShareLinkData({
                  isOpen: true,
                  memberName: member.name,
                  link: `https://app.figmamake.com/login?kid=${member.id}`
                })}
                className="text-slate-400 hover:text-indigo-500 bg-slate-50 hover:bg-indigo-50 rounded-full p-2 transition-colors flex items-center gap-1.5"
              >
                <LinkIcon className="w-4 h-4" />
                <span className="text-xs font-bold whitespace-nowrap hidden sm:inline">로그인 링크</span>
              </button>
            </div>
            
            <div className="bg-slate-50 rounded-xl p-3 flex justify-between items-center">
              <div className="flex items-center gap-2 text-slate-600 font-bold text-sm">
                <Trophy className="w-4 h-4 text-amber-500" />
                보유 포인트
              </div>
              <span className="font-extrabold text-slate-800">{member.points.toLocaleString()} P</span>
            </div>
            
            <div className="flex gap-2">
              <button 
                onClick={() => setStatsChild(member)}
                className="flex-1 py-2 rounded-xl bg-indigo-50 text-indigo-600 font-bold text-sm hover:bg-indigo-100 transition-colors"
              >
                활동 통계
              </button>
              <button 
                onClick={() => setPointModalChild(member)}
                className="flex-1 py-2 rounded-xl bg-slate-100 text-slate-600 font-bold text-sm hover:bg-slate-200 transition-colors"
              >
                포인트 지급/차감
              </button>
            </div>
          </motion.div>
        ))}

        <button 
          onClick={onOpenCreate}
          className="mt-2 bg-white border-2 border-dashed border-slate-300 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 hover:border-indigo-400 hover:bg-indigo-50 transition-colors group"
        >
          <div className="bg-slate-100 text-slate-400 p-3 rounded-full group-hover:bg-indigo-100 group-hover:text-indigo-500 transition-colors">
            <Plus className="w-6 h-6" />
          </div>
          <span className="font-bold text-slate-500 group-hover:text-indigo-500">아이 계정 추가하기</span>
        </button>

        <AnimatePresence>
          {shareLinkData && shareLinkData.isOpen && (
            <ShareLinkModal 
              isOpen={shareLinkData.isOpen}
              onClose={() => setShareLinkData(null)}
              title={`${shareLinkData.memberName}의 로그인 링크`}
              description="아래 링크나 QR코드를 아이의 핸드폰에 공유하면 바로 로그인할 수 있어요."
              linkToShare={shareLinkData.link}
            />
          )}

          {statsChild && (
            <ChildStatsView 
              key="stats-view"
              member={statsChild} 
              onBack={() => setStatsChild(null)} 
            />
          )}

          {pointModalChild && (
            <PointAdjustmentModal
              key="point-modal"
              isOpen={!!pointModalChild}
              onClose={() => setPointModalChild(null)}
              member={pointModalChild}
              onConfirm={(amount, reason, isEarn) => {
                console.log(`Point adjusted: ${isEarn ? '+' : '-'}${amount} for ${reason}`);
                setPointModalChild(null);
              }}
            />
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}