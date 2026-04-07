import React, { useState } from "react";
import { StoreBottomNav } from "./components/StoreBottomNav";
import { StoreView } from "./components/StoreView";
import { CouponView } from "./components/CouponView";
import { HomeView } from "./components/HomeView";
import { ProfileView } from "./components/ProfileView";
import { ParentView } from "./components/ParentView";
import { LoginView } from "./components/LoginView";
import confetti from "canvas-confetti";
import { Toaster } from "sonner";

export default function App() {
  const [currentTab, setCurrentTab] = useState("store"); // "home" | "store" | "coupons" | "profile"
  const [points, setPoints] = useState(1500);
  const [isParentMode, setIsParentMode] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleBuy = (rewardPoints: number) => {
    if (points >= rewardPoints) {
      setPoints(prev => prev - rewardPoints);
      
      confetti({
        particleCount: 120,
        spread: 80,
        origin: { y: 0.5 },
        colors: ['#4f46e5', '#ec4899', '#f59e0b', '#10b981'],
        disableForReducedMotion: true
      });
      
      // In a real app, this would also add the new coupon to the CouponView state
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex justify-center w-full font-sans">
      <div className="w-full max-w-md bg-[#F8FAFC] relative overflow-hidden flex flex-col min-h-screen shadow-2xl ring-1 ring-slate-900/5">
        <Toaster position="top-center" />
        {!isAuthenticated ? (
          <LoginView onLogin={() => setIsAuthenticated(true)} />
        ) : isParentMode ? (
          <ParentView onSwitchMode={() => setIsParentMode(false)} />
        ) : (
          <>
            {currentTab === "store" && <StoreView points={points} onBuy={handleBuy} />}
            {currentTab === "coupons" && <CouponView />}
            {currentTab === "home" && <HomeView points={points} setPoints={setPoints} />}
            {currentTab === "profile" && <ProfileView points={points} onSwitchToParentMode={() => setIsParentMode(true)} />}

            <StoreBottomNav currentTab={currentTab} onTabChange={setCurrentTab} />
          </>
        )}
      </div>
    </div>
  );
}