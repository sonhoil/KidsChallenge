import React from "react";
import { motion } from "motion/react";
import { clsx } from "clsx";

interface TypeSelectorProps {
  types: string[];
  selectedType: string;
  onSelect: (type: string) => void;
}

export function TypeSelector({ types, selectedType, onSelect }: TypeSelectorProps) {
  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-bold text-slate-700">미션 종류</label>
      <div className="flex p-1 bg-slate-100 rounded-2xl relative">
        {types.map((type) => {
          const isSelected = selectedType === type;
          return (
            <button
              key={type}
              type="button"
              onClick={() => onSelect(type)}
              className={clsx(
                "relative flex-1 py-3 text-sm font-bold rounded-xl outline-none tap-highlight-transparent z-10 transition-colors",
                isSelected ? "text-indigo-600" : "text-slate-500 hover:text-slate-700"
              )}
            >
              {isSelected && (
                <motion.div
                  layoutId="mission-type"
                  className="absolute inset-0 bg-white rounded-xl shadow-sm border border-slate-200"
                  transition={{ type: "spring", stiffness: 400, damping: 30 }}
                />
              )}
              <span className="relative z-10">{type}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}