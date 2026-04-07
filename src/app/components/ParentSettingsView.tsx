import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Bell, Shield, HelpCircle, LogOut, Users, Link as LinkIcon, ChevronRight } from "lucide-react";
import { clsx } from "clsx";
import { ShareLinkModal } from "./ShareLinkModal";

export function ParentSettingsView() {
  const [pushEnabled, setPushEnabled] = useState(true);
  const [showInviteModal, setShowInviteModal] = useState(false);

  const menuGroups = [
    {
      title: "알림",
      items: [
        {
          id: "push",
          icon: <Bell className="w-5 h-5 text-rose-500" />,
          label: "푸시 알림",
          color: "bg-rose-100",
          toggle: true,
          value: pushEnabled,
          onChange: () => setPushEnabled(!pushEnabled)
        }
      ]
    },
    {
      title: "가족 관리",
      items: [
        {
          id: "invite_admin",
          icon: <Users className="w-5 h-5 text-amber-500" />,
          label: "공동 관리자(부모님) 초대하기",
          color: "bg-amber-100",
          onClick: () => setShowInviteModal(true)
        }
      ]
    },
    {
      title: "계정 및 보안",
      items: [
        {
          id: "password",
          icon: <Shield className="w-5 h-5 text-indigo-500" />,
          label: "부모님 비밀번호 변경",
          color: "bg-indigo-100"
        }
      ]
    },
    {
      title: "지원",
      items: [
        {
          id: "help",
          icon: <HelpCircle className="w-5 h-5 text-teal-500" />,
          label: "고객 센터",
          color: "bg-teal-100"
        },
        {
          id: "logout",
          icon: <LogOut className="w-5 h-5 text-slate-500" />,
          label: "로그아웃",
          color: "bg-slate-200"
        }
      ]
    }
  ];

  return (
    <div className="flex flex-col h-full bg-slate-50 relative">
      <header className="px-6 py-6 bg-white/80 backdrop-blur-md sticky top-0 z-30 border-b border-slate-100 shadow-sm">
        <h1 className="text-2xl font-extrabold text-slate-800 tracking-tight">설정</h1>
        <p className="text-sm text-slate-500 font-bold mt-1">앱 환경을 관리하세요</p>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-32 flex flex-col gap-6">
        {menuGroups.map((group, groupIndex) => (
          <motion.div 
            key={groupIndex}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: groupIndex * 0.1 }}
            className="flex flex-col gap-2"
          >
            <h2 className="text-sm font-bold text-slate-400 px-2">{group.title}</h2>
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
              {group.items.map((item, index) => (
                <div 
                  key={item.id}
                  className={clsx(
                    "w-full flex items-center justify-between p-4 transition-colors hover:bg-slate-50 active:bg-slate-100",
                    index !== group.items.length - 1 && "border-b border-slate-100",
                    item.toggle ? "" : "cursor-pointer"
                  )}
                  onClick={item.onClick ? item.onClick : (!item.toggle && item.onChange ? item.onChange : undefined)}
                >
                  <div className="flex items-center gap-4">
                    <div className={clsx("p-2 rounded-xl", item.color)}>
                      {item.icon}
                    </div>
                    <span className="font-bold text-slate-700">{item.label}</span>
                  </div>
                  
                  {item.toggle ? (
                    <button 
                      onClick={(e) => { e.stopPropagation(); item.onChange?.(); }}
                      className={clsx(
                        "w-12 h-7 rounded-full transition-colors relative",
                        item.value ? "bg-indigo-500" : "bg-slate-200"
                      )}
                    >
                      <motion.div 
                        layout
                        className="w-5 h-5 bg-white rounded-full shadow-sm absolute top-1"
                        animate={{ left: item.value ? "24px" : "4px" }}
                        transition={{ type: "spring", stiffness: 500, damping: 30 }}
                      />
                    </button>
                  ) : (
                    <ChevronRight className="w-5 h-5 text-slate-300" />
                  )}
                </div>
              ))}
            </div>
          </motion.div>
        ))}

        <AnimatePresence>
          {showInviteModal && (
            <ShareLinkModal 
              isOpen={showInviteModal}
              onClose={() => setShowInviteModal(false)}
              title="공동 관리자 초대하기"
              description="이 초대 링크를 다른 부모님께 전달하면 관리 권한을 공유할 수 있어요."
              linkToShare="https://app.figmamake.com/invite/admin-1234abc"
            />
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}