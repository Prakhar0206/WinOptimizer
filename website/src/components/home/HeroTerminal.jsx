import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle2, Copy } from 'lucide-react';

// --- Pipeline data ---
const PIPELINE_STEPS = [
  { delay: 700,  text: <><span className="text-yellow-300 font-bold">[1/8]</span> Creating System Restore Point...<div className="text-green-400 ml-8">[SUCCESS] Restore point &apos;WinOptimizer-Backup&apos; created.</div></> },
  { delay: 1400, text: <><span className="text-yellow-300 font-bold">[2/8]</span> Tuning Windows Services...<div className="text-green-400 ml-8">[SUCCESS] Disabled Telemetry &amp; Unnecessary Services.</div></> },
  { delay: 1100, text: <><span className="text-yellow-300 font-bold">[3/8]</span> Scanning Boot Sequence...<div className="text-green-400 ml-8">[SUCCESS] 12 Bloatware Apps Disabled from Startup.</div></> },
  { delay: 1800, text: <><span className="text-yellow-300 font-bold">[4/8]</span> Trimming Idle Process Working Sets...<div className="text-gray-400 ml-8">RAM Before: 11.4 GB &nbsp;|&nbsp; RAM After: 7.2 GB</div><div className="text-green-400 ml-8">[SUCCESS] RAM Freed: 4.2 GB</div></> },
  { delay: 900,  text: <><span className="text-yellow-300 font-bold">[5/8]</span> Applying Privacy Shield...<div className="text-green-400 ml-8">[SUCCESS] 15 Telemetry Keys Locked.</div></> },
  { delay: 1600, text: <><span className="text-yellow-300 font-bold">[6/8]</span> Deep Disk Cleanup...<div className="text-green-400 ml-8">[SUCCESS] Cleaned 12.8 GB total data.</div></> },
  { delay: 800,  text: <><span className="text-yellow-300 font-bold">[7/8]</span> Resetting TCP/IP Stack...<div className="text-green-400 ml-8">[SUCCESS] DNS Flushed &amp; Adapters Optimized.</div></> },
  { delay: 700,  text: <><span className="text-yellow-300 font-bold">[8/8]</span> Cleaning Old Logs...<div className="text-green-400 ml-8">[SUCCESS] Operation Complete.</div></> },
];

export function HeroTerminal() {
  const [copied, setCopied] = useState(false);
  const codeString = `Set-ExecutionPolicy Bypass -Scope Process -Force\n.\\WinOptimizer.ps1`;

  // Interaction State
  const [phase, setPhase] = useState('idle'); // idle | typing | running | done
  const [visibleLines, setVisibleLines] = useState([]);
  const scrollRef = useRef(null);

  // Auto-scroll Down
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [visibleLines, phase]);

  const handlePromptClick = async () => {
    if (phase !== 'idle') return;

    // Typing phase
    setPhase('typing');
    await new Promise(r => setTimeout(r, 1800));

    // Banner appears
    setPhase('running');
    const banner = { 
      id: 'banner', 
      content: <div className="text-cyan-400 font-bold mb-4 drop-shadow-[0_0_5px_rgba(34,211,238,0.8)]">{'=== Optimizer v4.0 started ==='}</div> 
    };
    setVisibleLines([banner]);
    await new Promise(r => setTimeout(r, 700));

    // Stream pipeline steps
    let lines = [banner];
    for (let i = 0; i < PIPELINE_STEPS.length; i++) {
      await new Promise(r => setTimeout(r, PIPELINE_STEPS[i].delay));
      lines = [...lines, { id: `s${i}`, content: <div className="mb-2">{PIPELINE_STEPS[i].text}</div> }];
      setVisibleLines(lines);
    }

    // Complete
    await new Promise(r => setTimeout(r, 900));
    setPhase('done');
  };

  return (
    <motion.div 
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2, duration: 0.8, ease: "easeOut" }}
      className="w-full max-w-2xl mx-auto mt-12 rounded-xl overflow-hidden border border-white/10 shadow-[0_0_50px_rgba(34,211,238,0.15)] bg-black/50 backdrop-blur-xl relative flex flex-col h-[400px]"
    >
      {/* Title bar */}
      <div className="flex items-center justify-between px-4 py-3 bg-white/5 border-b border-white/5 shrink-0">
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
          title="Copy fast run script"
        >
          {copied ? <CheckCircle2 className="w-4 h-4 text-green-400" /> : <Copy className="w-4 h-4" />}
          {copied && <span className="absolute -top-6 -right-2 text-[10px] text-green-400 drop-shadow-[0_0_5px_rgba(74,222,128,0.8)]">Copied!</span>}
        </button>
      </div>
      
      {/* Terminal body */}
      <div 
        ref={scrollRef}
        className="flex-1 p-6 font-mono text-sm leading-relaxed overflow-x-hidden overflow-y-auto terminal-scroll text-left"
        style={{ scrollbarWidth: 'thin', scrollbarColor: 'rgba(255,255,255,0.1) transparent' }}
      >
        <div className="text-white/50 mb-4 text-xs">
          Windows PowerShell<br />
          Copyright (C) Microsoft Corporation. All rights reserved.
        </div>

        {/* Static prompt line (Idle) */}
        {phase === 'idle' && (
          <div
            className="flex items-center gap-1 cursor-text group"
            onClick={handlePromptClick}
            title="Click to run Option 20 Pipeline"
          >
            <span className="text-gray-400 shrink-0">PS C:\Users\Admin&gt;</span>
            <span className="w-[8px] h-[15px] bg-white/70 animate-[blink-caret_1s_step-end_infinite] shrink-0" />
            {/* Ghost text */}
            <span className="text-white/25 italic ml-1 transition-colors group-hover:text-white/40 select-none">.\WinOptimizer.ps1</span>
          </div>
        )}

        {/* Typing phase */}
        {phase === 'typing' && (
          <div className="flex items-center gap-1 overflow-hidden">
            <span className="text-gray-400 shrink-0">PS C:\Users\Admin&gt;</span>
            <span
              className="text-gray-300 overflow-hidden whitespace-nowrap ml-1"
              style={{ animation: 'typing 1.6s steps(18, end) forwards', width: 0, display: 'inline-block' }}
            >
              .\WinOptimizer.ps1
            </span>
          </div>
        )}

        {/* Typed command (Stays visible after typing) */}
        {(phase === 'running' || phase === 'done') && (
          <div className="flex items-center gap-1 mb-4">
            <span className="text-gray-400 shrink-0">PS C:\Users\Admin&gt;</span>
            <span className="text-gray-300 ml-1">.\WinOptimizer.ps1</span>
          </div>
        )}

        {/* Pipeline lines */}
        <div className="space-y-1">
          <AnimatePresence initial={false}>
            {visibleLines.map(line => (
              <motion.div
                key={line.id}
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.3 }}
              >
                {line.content}
              </motion.div>
            ))}
          </AnimatePresence>
        </div>

        {/* Completion banner */}
        {phase === 'done' && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8 }}
            className="mt-6 flex flex-col items-start gap-4"
          >
            <div className="relative">
              <div className="absolute inset-0 bg-cyan-400/20 blur-md rounded-sm"></div>
              <span className="text-cyan-400 border border-cyan-400/30 px-3 py-1.5 rounded-sm bg-cyan-400/10 relative z-10 font-bold drop-shadow-[0_0_8px_rgba(34,211,238,1)]">
                All-in-One Optimization Complete
              </span>
            </div>
            <div className="flex items-center gap-1 text-gray-400">
              PS C:\Users\Admin&gt;
              <span className="w-[8px] h-[15px] bg-white/70 ml-1 animate-[blink-caret_1s_step-end_infinite]" />
            </div>
          </motion.div>
        )}

        {/* Running cursor */}
        {phase === 'running' && visibleLines.length > 0 && (
          <div className="mt-2 text-gray-400">
            <span className="w-[8px] h-[15px] bg-white/70 inline-block animate-[blink-caret_1s_step-end_infinite]" />
          </div>
        )}
      </div>
    </motion.div>
  );
}
