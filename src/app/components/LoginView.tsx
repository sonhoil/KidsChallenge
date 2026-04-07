import React from "react";
import { motion } from "motion/react";
import { Sparkles } from "lucide-react";

interface LoginViewProps {
  onLogin: () => void;
}

export function LoginView({ onLogin }: LoginViewProps) {
  return (
    <div className="flex flex-col h-full bg-white relative items-center justify-center p-6 flex-1">
      <div className="flex-1 flex flex-col items-center justify-center w-full max-w-sm mt-12">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: "spring", bounce: 0.5 }}
          className="bg-blue-100 p-6 rounded-full mb-6 shadow-inner"
        >
          <Sparkles className="w-16 h-16 text-blue-500" />
        </motion.div>
        
        <h1 className="text-3xl font-extrabold text-slate-800 mb-2 text-center">
          우리아이 첫 지갑
        </h1>
        <p className="text-slate-500 font-bold text-center mb-12">
          집안일을 하고 포인트를 모아<br/>원하는 보상을 받아보세요!
        </p>

        <div className="w-full flex flex-col gap-3 mt-8">
          <button
            onClick={onLogin}
            className="w-full bg-[#FEE500] hover:bg-[#FDD800] text-[#000000] font-bold py-4 px-6 rounded-2xl flex items-center justify-center gap-3 transition-transform active:scale-95 shadow-sm"
          >
            <svg viewBox="0 0 32 32" className="w-6 h-6 fill-current">
                <path d="M16 4.64c-6.96 0-12.64 4.48-12.64 10.08 0 3.52 2.32 6.64 5.76 8.48l-1.44 5.28c-.16.48.4.88.8.64l6.08-4.08c.48.08.96.08 1.44.08 6.96 0 12.64-4.48 12.64-10.08S22.96 4.64 16 4.64z"/>
            </svg>
            카카오로 시작하기
          </button>

          <button
            onClick={onLogin}
            className="w-full bg-white border-2 border-slate-200 hover:bg-slate-50 text-slate-700 font-bold py-4 px-6 rounded-2xl flex items-center justify-center gap-3 transition-transform active:scale-95 shadow-sm"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
            </svg>
            Google로 시작하기
          </button>
        </div>
      </div>
      
      <div className="mt-auto pt-8 pb-4">
        <p className="text-[11px] text-slate-400 text-center font-medium leading-relaxed">
          가입 시 서비스 이용약관 및 개인정보 처리방침에<br/>동의하게 됩니다.
        </p>
      </div>
    </div>
  );
}