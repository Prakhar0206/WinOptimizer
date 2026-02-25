import { motion } from 'framer-motion';
import { Shield, RefreshCw, PowerOff, Network, Radio } from 'lucide-react';

// ----------------------------------------
// Micro-Animations for Safety Pillars
// ----------------------------------------

function RestorePointAnimation() {
  return (
    <div className="h-32 w-full flex items-center justify-center relative mb-6 overflow-hidden rounded-xl bg-black/40 border border-white/5 group-hover:border-cyan-500/30 transition-colors">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(34,211,238,0.1)_0%,transparent_70%)] opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
      
      {/* Grid Background */}
      <div className="absolute inset-0 opacity-[0.03] bg-[linear-gradient(rgba(255,255,255,1)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,1)_1px,transparent_1px)] bg-[size:12px_12px]" />

      {/* Timeline track */}
      <div className="absolute top-1/2 left-4 right-4 h-0.5 bg-white/10 -translate-y-1/2 rounded-full overflow-hidden"></div>
      
      {/* Dynamic Connection Line / Rollback Laser */}
      <motion.div
        className="absolute top-1/2 left-[20%] h-0.5 w-[55%] -translate-y-1/2 origin-left z-0 rounded-full"
        animate={{
          scaleX: [0, 1, 1, 1, 0, 0],
          backgroundColor: ["rgba(34,211,238,0)", "rgba(34,211,238,0.5)", "rgba(239,68,68,0.8)", "rgba(74,222,128,1)", "rgba(74,222,128,0)", "rgba(74,222,128,0)"],
        }}
        style={{ willChange: 'transform, background-color' }}
        transition={{ duration: 6, repeat: Infinity, times: [0, 0.4, 0.45, 0.5, 0.6, 1], ease: "easeInOut" }}
      />

      {/* Safe Origin Anchor */}
      <motion.div 
        animate={{ scale: [1, 1.2, 1, 1.5, 1] }}
        transition={{ duration: 6, repeat: Infinity, times: [0, 0.2, 0.4, 0.55, 1] }}
        style={{ willChange: 'transform' }}
        className="absolute left-[20%] top-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-green-400 z-10 flex items-center justify-center shadow-[0_0_15px_rgba(74,222,128,0.6)]"
      >
        <div className="w-1.5 h-1.5 bg-black rounded-full" />
      </motion.div>

      {/* Moving System State Block */}
      <motion.div 
        animate={{ 
          x: ["0vw", "12vw", "12vw", "12vw", "0vw", "0vw"],
          backgroundColor: ["rgba(34,211,238,0.1)", "rgba(34,211,238,0.1)", "rgba(239,68,68,0.2)", "rgba(239,68,68,0.2)", "rgba(74,222,128,0.8)", "rgba(34,211,238,0.1)"],
          borderColor: ["rgba(34,211,238,0.5)", "rgba(34,211,238,0.5)", "rgba(239,68,68,0.8)", "rgba(239,68,68,0.8)", "rgba(74,222,128,1)", "rgba(34,211,238,0.5)"],
          scale: [1, 1, 1.2, 0, 1.2, 1],
          opacity: [1, 1, 1, 0, 1, 1]
        }}
        style={{ willChange: 'transform' }}
        transition={{ duration: 6, repeat: Infinity, ease: "easeInOut", times: [0, 0.4, 0.45, 0.5, 0.55, 0.65] }}
        className="absolute left-[20%] top-1/2 -translate-y-1/2 w-8 h-8 rounded border-2 z-20 flex items-center justify-center backdrop-blur-md -ml-4"
      >
        <motion.div
          animate={{ rotate: [0, 180, 180, 360, 360, 360] }}
          transition={{ duration: 6, repeat: Infinity, times: [0, 0.4, 0.45, 0.5, 0.55, 1] }}
        >
          <RefreshCw className="w-4 h-4 text-white drop-shadow-[0_0_5px_rgba(255,255,255,0.5)]" />
        </motion.div>
      </motion.div>
      
      {/* Critical Error Glitch Rings */}
      <motion.div
         animate={{ opacity: [0, 0, 1, 0, 0], scale: [0.5, 0.5, 1.8, 2.5, 0.5] }}
         transition={{ duration: 6, repeat: Infinity, times: [0, 0.42, 0.45, 0.5, 1] }}
         className="absolute left-[75%] top-1/2 -translate-y-1/2 w-12 h-12 border border-red-500/80 bg-red-500/20 rounded-full flex items-center justify-center -ml-6 blur-[1px]"
         style={{ willChange: 'transform, opacity' }}
      >
        <div className="w-full h-full border-t-2 border-red-400 rounded-full animate-spin" style={{ animationDuration: '0.3s' }} />
      </motion.div>
    </div>
  );
}

function WhitelistAnimation() {
  return (
    <div className="h-32 w-full flex items-center justify-center relative mb-6 overflow-hidden rounded-xl bg-black/40 border border-white/5 group-hover:border-blue-500/30 transition-colors">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(59,130,246,0.15)_0%,transparent_70%)] opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
      
      {/* The Core App */}
      <motion.div 
        animate={{ scale: [1, 1.1, 1] }}
        transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
        className="w-12 h-12 rounded-xl bg-blue-500/20 border-2 border-blue-400 flex items-center justify-center z-10 shadow-[0_0_30px_rgba(59,130,246,0.6)] backdrop-blur-sm"
      >
        <PowerOff className="w-6 h-6 text-blue-300 drop-shadow-[0_0_8px_rgba(147,197,253,0.8)]" />
      </motion.div>

      {/* Protective Forcefield Rings */}
      {[1, 2].map((i) => (
        <motion.div 
          key={i}
          animate={{ scale: [1, 1.2 + i * 0.1, 1], opacity: [0.4, 0.1, 0.4] }}
          transition={{ duration: 2.5, repeat: Infinity, delay: i * 0.5, ease: "easeInOut" }}
          className="absolute rounded-full border border-blue-400/50 shadow-[inset_0_0_20px_rgba(59,130,246,0.3)] z-0"
          style={{ width: `${4 + i * 1.5}rem`, height: `${4 + i * 1.5}rem` }}
        />
      ))}

      {/* Threat 1 Bouncing Off */}
      <motion.div
        animate={{ 
          x: [-60, -30, -30, -60],
          y: [0, 0, 0, -20],
          opacity: [0, 1, 0, 0],
          scale: [1, 1, 2, 0]
        }}
        transition={{ duration: 2, repeat: Infinity, times: [0, 0.4, 0.5, 1], ease: "easeIn" }}
        className="absolute left-1/2 top-1/2 -translate-y-1/2 w-2 h-2 rounded-full bg-red-500 shadow-[0_0_10px_rgba(239,68,68,1)]"
      />
      
      {/* Threat 2 Bouncing Off */}
      <motion.div
        animate={{ 
          x: [60, 30, 30, 60],
          y: [20, 10, 10, 40],
          opacity: [0, 1, 0, 0],
          scale: [1, 1, 2, 0]
        }}
        transition={{ duration: 2.5, repeat: Infinity, delay: 0.5, times: [0, 0.4, 0.5, 1], ease: "easeIn" }}
        className="absolute left-1/2 top-1/2 -translate-y-1/2 w-2.5 h-2.5 rounded-full bg-red-500 shadow-[0_0_12px_rgba(239,68,68,1)]"
      />

      {/* Forcefield Impact Flares */}
      <motion.div
        animate={{ opacity: [0, 0.8, 0], scale: [0.8, 1.2, 1.5] }}
        transition={{ duration: 2, repeat: Infinity, times: [0, 0.4, 0.7] }}
        className="absolute left-[35%] top-1/2 -translate-y-1/2 w-8 h-16 rounded-full bg-blue-300/30 blur-md pointer-events-none"
      />
      <motion.div
        animate={{ opacity: [0, 0.6, 0], scale: [0.8, 1.2, 1.5] }}
        transition={{ duration: 2.5, repeat: Infinity, delay: 0.5, times: [0, 0.4, 0.7] }}
        className="absolute right-[35%] top-[60%] -translate-y-1/2 w-8 h-16 rounded-full bg-blue-300/30 blur-md pointer-events-none"
      />
    </div>
  );
}

function NetworkSonarAnimation() {
  return (
    <div className="h-32 w-full flex items-center justify-center relative mb-6 overflow-hidden rounded-xl bg-black/40 border border-white/5 group-hover:border-purple-500/30 transition-colors">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(168,85,247,0.15)_0%,transparent_70%)] opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>

      {/* Radar Grid */}
      <div className="absolute inset-0 opacity-[0.15] bg-[linear-gradient(rgba(168,85,247,0.4)_1px,transparent_1px),linear-gradient(90deg,rgba(168,85,247,0.4)_1px,transparent_1px)] bg-[size:20px_20px]" />

      {/* Advanced Rotating Radar Sweep */}
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
        className="absolute inset-0 z-0 origin-center mix-blend-screen"
      >
        <div 
          className="absolute inset-0 opacity-60"
          style={{ background: "conic-gradient(from 0deg, transparent 0deg, transparent 270deg, rgba(168,85,247,0.2) 330deg, rgba(168,85,247,0.8) 360deg)" }}
        />
        {/* Leading edge laser */}
        <div className="absolute top-0 left-1/2 w-0.5 h-1/2 bg-purple-300 origin-bottom shadow-[0_0_15px_rgba(216,180,254,1)] -translate-x-1/2" />
      </motion.div>

      {/* Center Radar Dish */}
      <div className="absolute z-10 flex items-center justify-center w-8 h-8 rounded-full bg-black/90 border-2 border-purple-500 shadow-[0_0_20px_rgba(168,85,247,0.6)] backdrop-blur-md">
        <Radio className="w-4 h-4 text-purple-300" />
      </div>

      {/* Radar Ping Rings */}
      <motion.div 
        animate={{ scale: [0, 4], opacity: [0.8, 0] }}
        transition={{ duration: 2, repeat: Infinity, ease: "easeOut" }}
        className="absolute w-16 h-16 rounded-full border border-purple-400/50 z-0 pointer-events-none"
      />

      {/* Safe Node */}
      <motion.div 
        animate={{ opacity: [0.4, 1, 0.4], scale: [1, 1.3, 1] }} 
        transition={{ duration: 4, repeat: Infinity, delay: 0.8 }} 
        className="absolute left-[20%] top-[25%] w-3 h-3 rounded-full bg-cyan-400 shadow-[0_0_15px_rgba(34,211,238,1)] z-20" 
      />
      
      {/* Dangerous/VPN Node Reacting to Ping */}
      <motion.div 
        animate={{ backgroundColor: ["#3f3f46", "#ef4444", "#3f3f46"], scale: [1, 1.2, 1] }}
        transition={{ duration: 4, repeat: Infinity, delay: 1.8, times: [0, 0.1, 0.3] }}
        className="absolute right-[25%] bottom-[20%] w-6 h-6 rounded flex items-center justify-center border border-red-500/80 z-20 shadow-[0_0_20px_rgba(239,68,68,0.5)] bg-black/80"
      >
        <Network className="w-3 h-3 text-white" />
        
        {/* Firewall Exclusion Shield */}
        <motion.div 
          animate={{ scale: [1, 1.5, 1.3], opacity: [0, 1, 0] }}
          transition={{ duration: 4, repeat: Infinity, delay: 1.8, times: [0, 0.1, 0.5] }}
          className="absolute inset-0 w-10 h-10 -m-2 rounded-full border border-dashed border-red-400"
        />
      </motion.div>
      
      {/* Continuous Stream of Safe Data Packets */}
      <svg className="absolute inset-0 w-full h-full pointer-events-none z-10">
        <path 
          d="M 10 30 Q 150 30 150 64 Q 150 90 290 90" 
          fill="none" 
          stroke="rgba(34,211,238,0.15)" 
          strokeWidth="2" 
        />
        {/* Animated Data Stream */}
        <motion.path 
          d="M 10 30 Q 150 30 150 64 Q 150 90 290 90" 
          fill="none" 
          stroke="#22d3ee" 
          strokeWidth="3" 
          strokeDasharray="6 24"
          animate={{ strokeDashoffset: [0, -120] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
          style={{ filter: "drop-shadow(0 0 6px #22d3ee)" }}
        />
      </svg>
    </div>
  );
}


export function SafetyGuarantee() {
  return (
    <section className="mb-40 relative z-10">
      <div className="bg-black/60 border border-white/10 rounded-[2.5rem] p-8 md:p-16 backdrop-blur-xl shadow-[0_0_60px_rgba(0,0,0,0.6)] relative overflow-hidden">
        {/* Subtle radial spotlight */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[80%] h-[300px] bg-[radial-gradient(ellipse_at_top,rgba(74,222,128,0.1)_0%,transparent_70%)] pointer-events-none mix-blend-screen"></div>

        <div className="text-center mb-20 relative">
          <div className="inline-block p-5 rounded-full bg-green-400/5 border border-green-400/20 mb-8 ring-1 ring-green-400/10 relative shadow-[0_0_20px_rgba(74,222,128,0.2)]">
            <div className="absolute inset-0 rounded-full bg-green-400/10 blur-xl animate-pulse"></div>
            <Shield className="w-12 h-12 text-green-400 drop-shadow-[0_0_15px_rgba(74,222,128,0.6)] relative z-10" />
          </div>
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-extrabold tracking-tight mb-6 text-transparent bg-clip-text bg-gradient-to-b from-white to-white/60 drop-shadow-[0_2px_10px_rgba(255,255,255,0.1)]">The Safety Guarantee</h2>
          <p className="text-muted text-lg md:text-xl max-w-2xl mx-auto leading-relaxed">We don't break Windows. WinOptimizer uses smart-detection algorithms to adapt to your hardware layout before making a single edit.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12 relative z-10">
          
          {/* Pillar 1: Backups */}
          <div className="text-left group bg-white/[0.02] hover:bg-white/[0.04] p-6 rounded-2xl border border-white/5 hover:border-white/10 transition-all duration-500 hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(34,211,238,0.05)]">
            <RestorePointAnimation />
            <div className="font-mono text-cyan-400 bg-cyan-400/10 border border-cyan-400/20 text-[10px] px-2.5 py-1 rounded inline-block mb-4 font-semibold tracking-wider transition-all">RESTORE POINTS</div>
            <h3 className="font-semibold text-xl mb-3 text-white/90 group-hover:text-white transition-colors">Automated Backups</h3>
            <p className="text-sm text-muted leading-relaxed group-hover:text-white/70 transition-colors">Built-in Restore Point creation and automated state backups configured for the All-in-One pipeline. Rollback safely anytime.</p>
          </div>
          
          {/* Pillar 2: Whitelists */}
          <div className="text-left group bg-white/[0.02] hover:bg-white/[0.04] p-6 rounded-2xl border border-white/5 hover:border-white/10 transition-all duration-500 hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(59,130,246,0.05)]">
            <WhitelistAnimation />
            <div className="font-mono text-blue-400 bg-blue-500/10 border border-blue-500/20 text-[10px] px-2.5 py-1 rounded inline-block mb-4 font-semibold tracking-wider transition-all">WHITELISTS</div>
            <h3 className="font-semibold text-xl mb-3 text-white/90 group-hover:text-white transition-colors">28 Protected Processes</h3>
            <p className="text-sm text-muted leading-relaxed group-hover:text-white/70 transition-colors">A hardcoded list of essential system apps, security tools, and browsers that are protected by our forcefield.</p>
          </div>

          {/* Pillar 3: Network Safeties */}
          <div className="text-left group bg-white/[0.02] hover:bg-white/[0.04] p-6 rounded-2xl border border-white/5 hover:border-white/10 transition-all duration-500 hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(168,85,247,0.05)]">
            <NetworkSonarAnimation />
            <div className="font-mono text-purple-400 bg-purple-500/10 border border-purple-500/20 text-[10px] px-2.5 py-1 rounded inline-block mb-4 font-semibold tracking-wider transition-all">VM & VPN DETECT</div>
            <h3 className="font-semibold text-xl mb-3 text-white/90 group-hover:text-white transition-colors">Network Safeties</h3>
            <p className="text-sm text-muted leading-relaxed group-hover:text-white/70 transition-colors">Sonar sweep automatically detects 17 VPN/VM adapters and Domain-joined PCs, actively routing around destructive resets.</p>
          </div>

        </div>
      </div>
    </section>
  );
}