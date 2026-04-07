import React, { useState } from "react";
import { motion } from "motion/react";
import { X, Check, User, Image as ImageIcon } from "lucide-react";
import { clsx } from "clsx";

interface CreateMemberViewProps {
  onClose: () => void;
}

export function CreateMemberView({ onClose }: CreateMemberViewProps) {
  const [name, setName] = useState("");
  const [age, setAge] = useState("");
  const [selectedAvatar, setSelectedAvatar] = useState(0);

  const avatars = [
    "https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=200",
    "https://images.unsplash.com/photo-1519689680058-324335c77eba?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTczMzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=200",
    "https://images.unsplash.com/photo-1544281676-47677d2427a1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwzfHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTczMzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=200",
    "https://images.unsplash.com/photo-1513379733131-47fc74b45fc7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHw0fHxoYXBweSUyMGtpZCUyMHBvcnRyYWl0fGVufDF8fHx8MTczMzE0Mjg3OHww&ixlib=rb-4.1.0&q=80&w=200",
  ];

  const handleSave = () => {
    // 실제 환경에서는 여기서 부모 컴포넌트나 상태 관리 라이브러리로 새 아이 계정 데이터를 전달합니다.
    onClose();
  };

  return (
    <motion.div
      initial={{ y: "100%" }}
      animate={{ y: 0 }}
      exit={{ y: "100%" }}
      transition={{ type: "spring", damping: 25, stiffness: 200 }}
      className="fixed inset-0 z-50 bg-slate-50 flex flex-col"
    >
      <header className="px-5 py-4 bg-white border-b border-slate-100 shadow-sm flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center gap-3">
          <button 
            onClick={onClose}
            className="p-2 -ml-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-extrabold text-slate-800">아이 계정 추가</h1>
        </div>
        <button 
          onClick={handleSave}
          disabled={!name}
          className="bg-indigo-600 text-white px-4 py-2 rounded-xl font-bold text-sm disabled:opacity-50 disabled:bg-slate-300 transition-colors flex items-center gap-1.5"
        >
          <Check className="w-4 h-4 stroke-[3]" />
          저장
        </button>
      </header>

      <main className="flex-1 overflow-y-auto p-5 pb-safe flex flex-col gap-8">
        {/* Name */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <User className="w-4 h-4" /> 이름 (또는 닉네임)
          </label>
          <input 
            type="text" 
            placeholder="아이 이름을 입력해주세요" 
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full bg-white border border-slate-200 rounded-2xl px-4 py-4 font-bold text-slate-800 placeholder:text-slate-300 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 shadow-sm transition-all"
          />
        </section>

        {/* Age */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            나이 (선택사항)
          </label>
          <input 
            type="number" 
            placeholder="예: 8" 
            value={age}
            onChange={(e) => setAge(e.target.value)}
            className="w-full bg-white border border-slate-200 rounded-2xl px-4 py-4 font-bold text-slate-800 placeholder:text-slate-300 focus:outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 shadow-sm transition-all"
          />
        </section>

        {/* Avatar Selection */}
        <section className="flex flex-col gap-3">
          <label className="text-sm font-bold text-slate-500 flex items-center gap-1.5">
            <ImageIcon className="w-4 h-4" /> 프로필 사진
          </label>
          <div className="grid grid-cols-4 gap-3">
            {avatars.map((url, index) => (
              <button
                key={index}
                onClick={() => setSelectedAvatar(index)}
                className={clsx(
                  "aspect-square rounded-2xl overflow-hidden border-2 transition-all",
                  selectedAvatar === index
                    ? "border-indigo-500 shadow-[0_0_0_2px_rgba(99,102,241,0.2)] scale-105"
                    : "border-transparent opacity-60 hover:opacity-100"
                )}
              >
                <img src={url} alt={`Avatar ${index}`} className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        </section>
      </main>
    </motion.div>
  );
}