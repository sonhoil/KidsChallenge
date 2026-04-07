import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { 
  Plus, 
  CheckCircle2, 
  Clock, 
  ChevronRight,
  ShieldCheck,
  UserCircle
} from "lucide-react";
import { ParentBottomNav } from "./ParentBottomNav";
import { PendingCard } from "./PendingCard";
import { ParentMembersView } from "./ParentMembersView";
import { ParentMissionsView } from "./ParentMissionsView";
import { ParentStoreView } from "./ParentStoreView";
import { ParentSettingsView } from "./ParentSettingsView";
import { CreateMissionView } from "./CreateMissionView";
import { CreateRewardView } from "./CreateRewardView";
import { CreateMemberView } from "./CreateMemberView";

interface ParentViewProps {
  onSwitchMode: () => void;
}

export function ParentView({ onSwitchMode }: ParentViewProps) {
  const [activeTab, setActiveTab] = useState("dashboard"); // dashboard, missions, members, store, settings
  const [showCreateMission, setShowCreateMission] = useState(false);
  const [showCreateReward, setShowCreateReward] = useState(false);
  const [showCreateMember, setShowCreateMember] = useState(false);
  const [pendingMissions, setPendingMissions] = useState([
    {
      id: 1,
      kidName: "민수",
      avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
      taskName: "방 청소하기",
      points: 100,
      timeAgo: "10분 전"
    },
    {
      id: 2,
      kidName: "지은",
      avatarUrl: "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=1080",
      taskName: "수학 숙제 3장 풀기",
      points: 150,
      timeAgo: "1시간 전"
    }
  ]);

  const handleApprove = (id: number) => {
    setPendingMissions(prev => prev.filter(m => m.id !== id));
  };

  const handleReject = (id: number) => {
    setPendingMissions(prev => prev.filter(m => m.id !== id));
  };

  const renderContent = () => {
    switch (activeTab) {
      case "missions":
        return <ParentMissionsView onOpenCreate={() => setShowCreateMission(true)} />;
      case "members":
        return <ParentMembersView onOpenCreate={() => setShowCreateMember(true)} />;
      case "store":
        return <ParentStoreView onOpenCreate={() => setShowCreateReward(true)} />;
      case "settings":
        return <ParentSettingsView />;
      case "dashboard":
      default:
        return (
          <div className="flex flex-col h-full bg-slate-50 relative">
            <header className="px-6 pt-12 pb-6 bg-white border-b border-slate-200 shadow-sm sticky top-0 z-30">
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-2 text-indigo-600 font-bold bg-indigo-50 px-3 py-1.5 rounded-full text-sm">
                  <ShieldCheck className="w-4 h-4" />
                  <span>부모님 모드</span>
                </div>
                <button 
                  onClick={onSwitchMode}
                  className="flex items-center gap-1.5 text-slate-500 font-bold text-sm bg-slate-100 px-3 py-1.5 rounded-full hover:bg-slate-200 transition-colors"
                >
                  <UserCircle className="w-4 h-4" />
                  <span>아이 모드로 전환</span>
                </button>
              </div>
              
              <div>
                <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight leading-tight mb-1">
                  승인 대기 중인 미션
                </h1>
                <p className="text-slate-500 font-medium text-sm">
                  <span className="text-indigo-600 font-bold">{pendingMissions.length}건</span>의 미션이 승인을 기다리고 있어요
                </p>
              </div>
            </header>

            <main className="flex-1 overflow-y-auto px-5 py-6 pb-32 flex flex-col gap-6">
              {/* Actions */}
              <div className="grid grid-cols-2 gap-3">
                <button 
                  onClick={() => setShowCreateMission(true)}
                  className="bg-white border border-slate-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 shadow-sm hover:border-indigo-300 hover:bg-indigo-50 transition-all group"
                >
                  <div className="bg-indigo-100 text-indigo-600 p-2.5 rounded-full group-hover:scale-110 transition-transform">
                    <Plus className="w-5 h-5" />
                  </div>
                  <span className="font-bold text-slate-700 text-sm">새 미션 만들기</span>
                </button>
                
                <button className="bg-white border border-slate-200 rounded-2xl p-4 flex flex-col items-center justify-center gap-2 shadow-sm hover:border-indigo-300 hover:bg-indigo-50 transition-all group">
                  <div className="bg-emerald-100 text-emerald-600 p-2.5 rounded-full group-hover:scale-110 transition-transform">
                    <CheckCircle2 className="w-5 h-5" />
                  </div>
                  <span className="font-bold text-slate-700 text-sm">승인 내역 보기</span>
                </button>
              </div>

              {/* Pending List */}
              <div>
                <div className="flex items-center justify-between mb-4 px-1">
                  <h2 className="font-bold text-slate-800 text-lg flex items-center gap-2">
                    <Clock className="w-5 h-5 text-indigo-500" /> 
                    승인 요청
                  </h2>
                  <button className="text-slate-400 font-bold text-sm flex items-center hover:text-indigo-500 transition-colors">
                    전체보기 <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
                
                <div className="flex flex-col gap-3">
                  <AnimatePresence>
                    {pendingMissions.length > 0 ? (
                      pendingMissions.map((mission) => (
                        <PendingCard 
                          key={mission.id} 
                          {...mission} 
                          onApprove={handleApprove} 
                          onReject={handleReject} 
                        />
                      ))
                    ) : (
                      <motion.div 
                        initial={{ opacity: 0 }} 
                        animate={{ opacity: 1 }} 
                        className="bg-white border border-slate-200 border-dashed rounded-2xl p-10 flex flex-col items-center justify-center text-center gap-3"
                      >
                        <div className="bg-slate-100 p-4 rounded-full text-slate-300 mb-2">
                          <CheckCircle2 className="w-8 h-8" />
                        </div>
                        <div>
                          <p className="font-bold text-slate-700 text-lg">모두 확인했어요!</p>
                          <p className="text-slate-500 text-sm mt-1">새로운 승인 요청이 없습니다.</p>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              </div>
            </main>
          </div>
        );
    }
  };

  return (
    <>
      {renderContent()}
      <ParentBottomNav currentTab={activeTab} onTabChange={setActiveTab} />
      
      <AnimatePresence>
        {showCreateMission && (
          <CreateMissionView onClose={() => setShowCreateMission(false)} />
        )}
        {showCreateReward && (
          <CreateRewardView onClose={() => setShowCreateReward(false)} />
        )}
        {showCreateMember && (
          <CreateMemberView onClose={() => setShowCreateMember(false)} />
        )}
      </AnimatePresence>
    </>
  );
}