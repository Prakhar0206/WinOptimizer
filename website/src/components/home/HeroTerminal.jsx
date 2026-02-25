import { useState } from 'react';
import { motion } from 'framer-motion';
import { CheckCircle2, Copy } from 'lucide-react';

export function HeroTerminal() {
  const [copied, setCopied] = useState(false);
  const codeString = `Set-ExecutionPolicy Bypass -Scope Process -Force\n.\\WinOptimizer.ps1`;

  return (
    <motion.div 
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2, duration: 0.8, ease: "easeOut" }}
      className="w-full max-w-2xl mx-auto mt-12 rounded-xl overflow-hidden border border-white/10 shadow-[0_0_50px_rgba(34,211,238,0.15)] bg-black/50 backdrop-blur-xl relative"
    >
      <div className="flex items-center justify-between px-4 py-3 bg-white/5 border-b border-white/5">
        <div className="flex gap-2">
          <div className="w-3 h-3 rounded-full bg-red-500/80 shadow-[0_0_10px_rgba(239,68,68,0.5)]"></div>
          <div className="w-3 h-3 rounded-full bg-yellow-500/80 shadow-[0_0_10px_rgba(234,179,8,0.5)]"></div>
          <div className="w-3 h-3 rounded-full bg-green-500/80 shadow-[0_0_10px_rgba(34,197,94,0.5)]"></div>
        </div>
        <div className="text-xs text-muted font-mono font-medium">Administrator: Windows PowerShell</div>
        <button 
          onClick={() => {
            navigator.clipboard.writeText(codeString);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
          }} 
          className="text-muted hover:text-white transition-colors p-1 rounded-md hover:bg-white/10 relative" 
        >
          {copied ? <CheckCircle2 className="w-4 h-4 text-green-400" /> : <Copy className="w-4 h-4" />}
          {copied && <span className="absolute -top-6 -right-2 text-[10px] text-green-400 drop-shadow-[0_0_5px_rgba(74,222,128,0.8)]">Copied!</span>}
        </button>
      </div>
      
      <div className="p-6 font-mono text-sm leading-relaxed overflow-x-auto terminal-scroll text-left">
        <div className="text-gray-400 mb-2 whitespace-nowrap overflow-hidden animate-[typing_1s_steps(40,end)] border-r-2 border-transparent">
          PS C:\\Users\\Admin&gt; .\\WinOptimizer.ps1
        </div>
        
        <div className="space-y-2">
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.8 }}>
            <div className="text-cyan-400 font-bold mb-4 drop-shadow-[0_0_5px_rgba(34,211,238,0.8)]">=== Optimizer v4.0 started ===</div>
            <span className="text-cyan-400 font-bold">[1/8]</span> Creating System Restore Point... <span className="text-gray-500 opacity-50 ml-2">Verified.</span>
            <div className="text-green-400 mt-0.5 ml-8 font-medium drop-shadow-[0_0_3px_rgba(74,222,128,0.5)]">[SUCCESS] Restore point 'WinOptimizer-Backup' created</div>
          </motion.div>
          
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 1.5 }}>
            <span className="text-cyan-400 mt-2 block font-bold">[2/8]</span> Trimming idle process working sets...
            <div className="text-gray-400 ml-8">RAM Before: 11.4 GB</div>
            <div className="text-gray-400 ml-8">RAM After: 7.2 GB</div>
            <div className="text-green-400 mt-0.5 ml-8 font-medium drop-shadow-[0_0_3px_rgba(74,222,128,0.5)]">[SUCCESS] RAM Freed: 4.2 GB</div>
          </motion.div>

          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2.2 }}>
            <span className="text-cyan-400 mt-2 block font-bold">[3/8]</span> Deep Disk Space Cleanup...
            <div className="text-green-400 mt-0.5 ml-8 font-medium drop-shadow-[0_0_3px_rgba(74,222,128,0.5)]">[SUCCESS] Cleaned 12.8 GB total data.</div>
          </motion.div>

          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2.9 }} className="mt-4 flex items-center gap-2 relative">
            <div className="absolute inset-0 bg-cyan-400/20 blur-md rounded-sm"></div>
            <span className="text-cyan-400 border border-cyan-400/30 px-2 rounded-sm bg-cyan-400/10 relative z-10">All-in-One Optimization Complete</span>
            <span className="animate-blink text-cyan-400 font-bold drop-shadow-[0_0_8px_rgba(34,211,238,1)]">_</span>
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
}
