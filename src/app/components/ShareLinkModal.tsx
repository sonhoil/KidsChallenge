import React, { useState } from "react";
import { motion } from "motion/react";
import { X, Copy, QrCode, Share2, Check } from "lucide-react";

interface ShareLinkModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  description: string;
  linkToShare: string;
}

export function ShareLinkModal({ isOpen, onClose, title, description, linkToShare }: ShareLinkModalProps) {
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const handleCopy = () => {
    navigator.clipboard.writeText(linkToShare);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm"
        onClick={onClose}
      />
      
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="relative w-full max-w-sm bg-white rounded-3xl shadow-xl overflow-hidden z-10"
      >
        <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
          <h2 className="font-extrabold text-lg text-slate-800">{title}</h2>
          <button 
            onClick={onClose}
            className="p-2 -mr-2 text-slate-400 hover:text-slate-600 rounded-full hover:bg-slate-100 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 flex flex-col items-center">
          <p className="text-slate-500 font-bold text-sm text-center mb-6">
            {description}
          </p>

          <div className="bg-slate-50 border-2 border-slate-100 p-6 rounded-3xl mb-6 flex flex-col items-center justify-center gap-2">
            <QrCode className="w-24 h-24 text-indigo-500" />
            <span className="text-xs font-bold text-slate-400">QR 코드를 스캔하세요</span>
          </div>

          <div className="w-full relative">
            <div className="w-full bg-slate-50 border border-slate-200 rounded-2xl py-3 px-4 pr-12 font-medium text-slate-600 text-sm truncate select-all">
              {linkToShare}
            </div>
            <button 
              onClick={handleCopy}
              className="absolute right-2 top-1/2 -translate-y-1/2 p-2 bg-white text-slate-400 hover:text-indigo-600 rounded-xl shadow-sm border border-slate-100 transition-all hover:scale-105 active:scale-95"
            >
              {copied ? <Check className="w-4 h-4 text-emerald-500" /> : <Copy className="w-4 h-4" />}
            </button>
          </div>

          <button 
            onClick={() => {
              if (navigator.share) {
                navigator.share({
                  title: title,
                  text: description,
                  url: linkToShare
                });
              }
            }}
            className="w-full mt-4 bg-indigo-50 text-indigo-600 font-bold text-sm py-4 rounded-2xl flex items-center justify-center gap-2 hover:bg-indigo-100 transition-colors"
          >
            <Share2 className="w-4 h-4" />
            카카오톡 등 다른 앱으로 공유하기
          </button>
        </div>
      </motion.div>
    </div>
  );
}