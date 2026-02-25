import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { TerminalSquare, AlertTriangle, Check, Copy } from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs) {
  return twMerge(clsx(inputs));
}

function CopyableCode({ code }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(code);
    } else {
      const textArea = document.createElement("textarea");
      textArea.value = code;
      textArea.style.position = "absolute";
      textArea.style.left = "-999999px";
      document.body.appendChild(textArea);
      textArea.select();
      try { document.execCommand('copy'); } catch (error) { console.error(error); }
      document.body.removeChild(textArea);
    }
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="relative group bg-black/50 border border-white/10 rounded-lg p-3 font-mono text-sm text-cyan-300 overflow-hidden mt-2">
      <pre className="overflow-x-auto whitespace-pre-wrap pr-10">{code}</pre>
      <button
        onClick={handleCopy}
        title="Copy to clipboard"
        className="absolute top-2 right-2 p-1.5 rounded-md bg-white/10 hover:bg-white/20 text-gray-300 hover:text-white transition-all opacity-0 group-hover:opacity-100 focus:opacity-100"
      >
        {copied ? <Check className="w-4 h-4 text-green-400" /> : <Copy className="w-4 h-4" />}
      </button>
    </div>
  );
}

export function GuideSection() {
  const [activeTab, setActiveTab] = useState('standard');

  return (
    <motion.section 
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.6, ease: "easeOut" }}
      className="mb-32 relative z-10 max-w-4xl mx-auto"
    >
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-3/4 h-3/4 bg-cyan-900/10 blur-[100px] -z-10 rounded-full"></div>

      <div className="text-center mb-10">
        <h2 className="text-3xl font-bold tracking-tight mb-4 text-white drop-shadow-[0_2px_10px_rgba(255,255,255,0.1)]">How to Run</h2>
        <p className="text-muted text-lg">No installations. No background services. Just download and run.</p>
      </div>

      <div className="bg-black/80 border border-white/10 rounded-2xl overflow-hidden backdrop-blur-xl shadow-[0_0_40px_rgba(0,0,0,0.5)]">
        <div className="flex border-b border-white/10 pt-2 px-2 gap-2 bg-white/5">
          <button
            onClick={() => setActiveTab('standard')}
            className={cn(
              "px-6 py-3 font-medium text-sm rounded-t-lg transition-all relative outline-none",
              activeTab === 'standard' ? "text-cyan-400 bg-black/80 drop-shadow-[0_0_5px_rgba(34,211,238,0.5)]" : "text-muted hover:text-white hover:bg-white/5"
            )}
          >
            Standard User (.bat)
            {activeTab === 'standard' && (
              <motion.div layoutId="guideTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-cyan-400 shadow-[0_0_10px_rgba(34,211,238,1)]" />
            )}
          </button>
          <button
            onClick={() => setActiveTab('cli')}
            className={cn(
              "px-6 py-3 font-medium text-sm rounded-t-lg transition-all relative outline-none",
              activeTab === 'cli' ? "text-cyan-400 bg-black/80 drop-shadow-[0_0_5px_rgba(34,211,238,0.5)]" : "text-muted hover:text-white hover:bg-white/5"
            )}
          >
            Power User (CLI)
            {activeTab === 'cli' && (
              <motion.div layoutId="guideTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-cyan-400 shadow-[0_0_10px_rgba(34,211,238,1)]" />
            )}
          </button>
        </div>

        <div className="p-8">
          <AnimatePresence mode="wait" initial={false}>
            {activeTab === 'standard' ? (
              <motion.div 
                key="standard"
                initial={{ opacity: 0, x: -10, filter: "blur(4px)" }}
                animate={{ opacity: 1, x: 0, filter: "blur(0px)" }}
                exit={{ opacity: 0, x: 10, filter: "blur(4px)" }}
                transition={{ duration: 0.3 }}
                className="space-y-8"
              >
                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">1</div>
                  <div>
                    <h4 className="font-semibold text-white mb-1 group-hover:text-cyan-50 transition-colors">Download and Extract</h4>
                    <p className="text-muted text-sm leading-relaxed group-hover:text-gray-300 transition-colors">Download the latest release ZIP file and extract it to any folder on your PC.</p>
                  </div>
                </div>

                {/* Note Moved Here - with ml-12 to align nicely with the text */}
                <div className="ml-12 flex items-start gap-4 bg-cyan-900/20 border border-cyan-500/20 p-4 rounded-xl text-cyan-50 text-sm shadow-[0_0_30px_rgba(34,211,238,0.05)] backdrop-blur-md">
                  <AlertTriangle className="w-5 h-5 flex-shrink-0 mt-0.5 text-cyan-400 drop-shadow-[0_0_5px_rgba(34,211,238,0.5)]" />
                  <p className="leading-relaxed">
                    <strong className="text-cyan-300 drop-shadow-[0_0_2px_rgba(34,211,238,0.5)] font-semibold">Note on Windows SmartScreen:</strong> Windows might flag the downloaded <code className="font-mono bg-black/40 px-1 border border-white/5 rounded text-cyan-200">.bat</code> file because it is not digitally signed. To proceed, click <strong className="text-white">"More info"</strong> and then <strong className="text-cyan-300">"Run anyway"</strong>. WinOptimizer is entirely open-source, so you can inspect the code before running it.
                  </p>
                </div>

                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">2</div>
                  <div>
                    <h4 className="font-semibold text-white mb-1 group-hover:text-cyan-50 transition-colors">Run the Launcher</h4>
                    <p className="text-muted text-sm leading-relaxed group-hover:text-gray-300 transition-colors">Double-click <code className="bg-white/10 text-cyan-300 font-mono px-1.5 py-0.5 rounded border border-white/10 shadow-inner">Run-Optimizer.bat</code> script.</p>
                  </div>
                </div>

                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">3</div>
                  <div>
                    <h4 className="font-semibold text-white mb-1 group-hover:text-cyan-50 transition-colors">Grant Permissions</h4>
                    <p className="text-muted text-sm leading-relaxed group-hover:text-gray-300 transition-colors">It will automatically request Administrator privileges safely and launch the main menu.</p>
                  </div>
                </div>
              </motion.div>
            ) : (
              <motion.div 
                key="cli"
                initial={{ opacity: 0, x: 10, filter: "blur(4px)" }}
                animate={{ opacity: 1, x: 0, filter: "blur(0px)" }}
                exit={{ opacity: 0, x: -10, filter: "blur(4px)" }}
                transition={{ duration: 0.3 }}
                className="space-y-8"
              >
                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">1</div>
                  <div>
                    <h4 className="font-semibold text-white mb-1 group-hover:text-cyan-50 transition-colors">Download and Extract</h4>
                    <p className="text-muted text-sm leading-relaxed group-hover:text-gray-300 transition-colors">Download the latest release ZIP file and extract it to any folder on your PC.</p>
                  </div>
                </div>

                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">2</div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-white mb-2 group-hover:text-cyan-50 transition-colors">Open PowerShell & Navigate</h4>
                    <p className="text-muted text-sm mb-3 leading-relaxed group-hover:text-gray-300 transition-colors">Open PowerShell as Administrator and change directory to your extracted folder.</p>
                    <CopyableCode code={`cd "C:\\Path\\To\\Extracted\\WinOptimizer"`} />
                  </div>
                </div>

                <div className="flex gap-4 items-start group">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-400 flex items-center justify-center font-bold shadow-[0_0_15px_rgba(34,211,238,0.2)] group-hover:shadow-[0_0_20px_rgba(34,211,238,0.5)] transition-shadow">3</div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-white mb-2 group-hover:text-cyan-50 transition-colors">Execute the Script</h4>
                    <p className="text-muted text-sm mb-3 leading-relaxed group-hover:text-gray-300 transition-colors">Bypass the execution policy for the current process and run the script directly.</p>
                    <CopyableCode code={`Set-ExecutionPolicy Bypass -Scope Process -Force\n.\\WinOptimizer.ps1`} />
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </motion.section>
  );
}