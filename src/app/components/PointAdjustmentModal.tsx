import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Plus, Minus, Check } from "lucide-react";
import { clsx } from "clsx";

interface PointAdjustmentModalProps {
  isOpen: boolean;
  onClose: () => void;
  member: any;
  onConfirm: (amount: number, reason: string, isEarn: boolean) => void;
}

export function PointAdjustmentModal({ isOpen, onClose, member, onConfirm }: PointAdjustmentModalProps) {
  const [isEarn, setIsEarn] = useState(true);
  const [amount, setAmount] = useState("");
  const [reason, setReason] = useState("");

  if (!isOpen || !member) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!amount || !reason) return;
    onConfirm(Number(amount), reason, isEarn);
    setAmount("");
    setReason("");
    setIsEarn(true);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center sm:items-center p-0 sm:p-4">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm"
        onClick={onClose}
      />
      
      <motion.div
        initial={{ opacity: 0, y: "100%" }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: "100%" }}
        transition={{ type: "spring", damping: 30, stiffness: 400 }}
        className="relative w-full max-w-md bg-white rounded-t-3xl sm:rounded-3xl shadow-xl overflow-hidden z-10 flex flex-col max-h-[90vh]"
      >
        <div className="flex items-center justify-between px-6 py-5 border-b border-slate-100">
          <div>
            <h2 className="font-extrabold text-xl text-slate-800">포인트 관리</h2>
            <p className="text-sm font-medium text-slate-500 mt-0.5">{member.name}의 포인트 조절</p>
          </div>
          <button 
            onClick={onClose}
            className="p-2 -mr-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 flex flex-col gap-6 overflow-y-auto">
          <div className="flex bg-slate-100 p-1 rounded-2xl">
            <button
              type="button"
              onClick={() => setIsEarn(true)}
              className={clsx(
                "flex-1 py-3 px-4 rounded-xl text-sm font-bold transition-all flex items-center justify-center gap-2",
                isEarn ? "bg-white text-indigo-600 shadow-sm" : "text-slate-500 hover:text-slate-700"
              )}
            >
              <Plus className="w-4 h-4" />
              지급하기
            </button>
            <button
              type="button"
              onClick={() => setIsEarn(false)}
              className={clsx(
                "flex-1 py-3 px-4 rounded-xl text-sm font-bold transition-all flex items-center justify-center gap-2",
                !isEarn ? "bg-white text-rose-600 shadow-sm" : "text-slate-500 hover:text-slate-700"
              )}
            >
              <Minus className="w-4 h-4" />
              차감하기
            </button>
          </div>

          <div className="flex flex-col gap-4">
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 ml-1">포인트 양</label>
              <div className="relative">
                <input 
                  type="number"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  placeholder="예: 100"
                  className="w-full bg-slate-50 border border-slate-200 rounded-2xl py-4 px-5 font-bold text-slate-800 text-lg placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all pr-12"
                  required
                />
                <span className="absolute right-5 top-1/2 -translate-y-1/2 font-bold text-slate-400">P</span>
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 ml-1">사유 입력</label>
              <input 
                type="text"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder={isEarn ? "예: 방 청소 잘해서" : "예: 장난감 정리 안함"}
                className="w-full bg-slate-50 border border-slate-200 rounded-2xl py-4 px-5 font-bold text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                required
              />
            </div>
          </div>

          <button 
            type="submit"
            disabled={!amount || !reason}
            className={clsx(
              "w-full mt-2 font-bold text-lg py-4 rounded-2xl flex items-center justify-center gap-2 transition-all shadow-sm",
              !amount || !reason 
                ? "bg-slate-200 text-slate-400 cursor-not-allowed" 
                : isEarn 
                  ? "bg-indigo-500 hover:bg-indigo-600 text-white active:scale-[0.98]"
                  : "bg-rose-500 hover:bg-rose-600 text-white active:scale-[0.98]"
            )}
          >
            <Check className="w-5 h-5" />
            {isEarn ? "포인트 지급하기" : "포인트 차감하기"}
          </button>
        </form>
      </motion.div>
    </div>
  );
}