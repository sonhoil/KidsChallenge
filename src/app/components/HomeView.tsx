import React, { useState } from "react";
import { Header } from "./Header";
import { MissionCard } from "./MissionCard";
import { BookOpen, Trash2, Bed, Dog, Sparkles, Calendar } from "lucide-react";
import confetti from "canvas-confetti";
import { toast } from "sonner";

export function HomeView({ points, setPoints }: { points: number, setPoints: React.Dispatch<React.SetStateAction<number>> }) {
  const [missionStatuses, setMissionStatuses] = useState<Record<number, 'todo' | 'pending' | 'approved'>>({});

  const missions = [
    { id: 1, title: "방 청소하기", points: 100, icon: <Bed className="w-8 h-8" strokeWidth={2.5} /> },
    { id: 2, title: "강아지 산책", points: 200, icon: <Dog className="w-8 h-8" strokeWidth={2.5} /> },
    { id: 3, title: "책 1시간 읽기", points: 150, icon: <BookOpen className="w-8 h-8" strokeWidth={2.5} /> },
    { id: 4, title: "분리수거 돕기", points: 50, icon: <Trash2 className="w-8 h-8" strokeWidth={2.5} /> },
    { id: 5, title: "동생과 놀아주기", points: 300, icon: <Sparkles className="w-8 h-8" strokeWidth={2.5} /> },
  ];

  const handleComplete = (id: number, missionPoints: number, title: string) => {
    if (missionStatuses[id] && missionStatuses[id] !== 'todo') return;

    // 1단계: 승인 대기 상태로 변경
    setMissionStatuses((prev) => ({ ...prev, [id]: 'pending' }));
    toast.success(`'${title}' 완료! 부모님의 승인을 기다려주세요.`);

    // (시뮬레이션) 3초 후 부모님이 승인한 것처럼 자동 처리
    setTimeout(() => {
      setMissionStatuses((prev) => ({ ...prev, [id]: 'approved' }));
      setPoints((prev) => prev + missionPoints);
      
      toast.success(`부모님이 승인했어요! ${missionPoints}P가 지급되었습니다!`, {
        icon: '🎉',
        style: { background: '#10b981', color: '#fff', border: 'none' }
      });

      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
        colors: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444'],
        disableForReducedMotion: true
      });
    }, 3000);
  };

  return (
    <>
      <Header points={points} />
      <main className="flex-1 overflow-y-auto pb-36">
        <div className="px-6 mt-4 mb-6">
          <div className="flex items-center gap-2 mb-2">
            <Calendar className="w-6 h-6 text-blue-500" />
            <h2 className="text-xl font-extrabold text-slate-800">오늘 할 일</h2>
          </div>
          <p className="text-sm font-bold text-slate-500">오늘 끝내야 하는 미션들이에요. 화이팅!</p>
        </div>
        <div className="px-6 flex flex-col gap-4">
          {missions.map((mission) => (
            <MissionCard
              key={mission.id}
              title={mission.title}
              points={mission.points}
              icon={mission.icon}
              onComplete={() => handleComplete(mission.id, mission.points, mission.title)}
              status={missionStatuses[mission.id] || 'todo'}
            />
          ))}
        </div>
      </main>
    </>
  );
}