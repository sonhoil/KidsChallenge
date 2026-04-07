import React from "react";
import { motion, AnimatePresence } from "motion/react";
import { Check } from "lucide-react";
import { clsx } from "clsx";

export interface Kid {
  id: string;
  name: string;
  avatarUrl: string;
}

interface AssigneeSelectorProps {
  kids: Kid[];
  selectedIds: string[];
  onToggle: (id: string) => void;
}

export function AssigneeSelector({ kids, selectedIds, onToggle }: AssigneeSelectorProps) {
  return (
    <div className="flex flex-col gap-3">
      <label className="text-sm font-bold text-slate-700 flex justify-between items-center">
        할당할 아이 
        <span className="text-xs font-semibold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-full">
          {selectedIds.length > 0 ? `${selectedIds.length}명 선택됨` : "선택 안 됨"}
        </span>
      </label>
      <div className="flex gap-4 overflow-x-auto pb-2 -mx-6 px-6 no-scrollbar">
        {kids.map((kid) => {
          const isSelected = selectedIds.includes(kid.id);
          return (
            <button
              key={kid.id}
              type="button"
              onClick={() => onToggle(kid.id)}
              className="relative flex flex-col items-center gap-2 flex-shrink-0 group outline-none"
            >
              <div className="relative w-16 h-16 rounded-full overflow-hidden">
                <img
                  src={kid.avatarUrl}
                  alt={kid.name}
                  className={clsx(
                    "w-full h-full object-cover transition-all duration-300",
                    isSelected ? "ring-4 ring-indigo-500 ring-offset-2 scale-95" : "border-2 border-slate-200 group-hover:border-indigo-300"
                  )}
                />
                <AnimatePresence>
                  {isSelected && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.5 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 0.5 }}
                      className="absolute inset-0 bg-indigo-500/40 backdrop-blur-[2px] flex items-center justify-center"
                    >
                      <motion.div 
                        initial={{ y: 5 }} animate={{ y: 0 }}
                        className="bg-indigo-600 rounded-full p-1 shadow-sm"
                      >
                        <Check className="w-5 h-5 text-white stroke-[3]" />
                      </motion.div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
              <span className={clsx(
                "text-xs font-bold transition-colors",
                isSelected ? "text-indigo-700" : "text-slate-500"
              )}>
                {kid.name}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}