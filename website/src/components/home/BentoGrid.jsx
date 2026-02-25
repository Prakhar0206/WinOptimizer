import { motion } from 'framer-motion';
import { Shield, Zap, Laptop, Activity, CheckCircle2, ChevronRight, PlayCircle, Settings, Power } from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs) {
  return twMerge(clsx(inputs));
}

// ----------------------------------------
// Micro-Animations for Each Card
// ----------------------------------------

function AutomationAnimation() {
  return (
    <div className="absolute top-1/2 right-4 -translate-y-1/2 flex items-center gap-2 opacity-30 group-hover:opacity-100 transition-opacity duration-500">
      {[0, 1, 2].map((i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0.2 }}
          animate={{ opacity: [0.2, 1, 0.2] }}
          transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.3 }}
          className="w-1.5 h-8 bg-cyan-400 rounded-full shadow-[0_0_10px_rgba(34,211,238,0.8)]"
        />
      ))}
      <motion.div 
        animate={{ rotate: 360 }}
        transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
        className="ml-4 p-2 rounded-full border border-cyan-400/30"
        style={{ willChange: 'transform' }}
      >
        <Settings className="w-5 h-5 text-cyan-400" />
      </motion.div>
    </div>
  );
}

function PrivacyAnimation() {
  return (
    <div className="absolute inset-0 flex items-center justify-center overflow-hidden opacity-20 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-0">
      <motion.div 
        animate={{ scale: [1, 2.5], opacity: [0.5, 0] }}
        transition={{ duration: 2, repeat: Infinity, ease: "easeOut" }}
        className="absolute w-24 h-24 border border-cyan-500/50 rounded-full"
        style={{ willChange: 'transform, opacity' }}
      />
      <motion.div 
        animate={{ scale: [1, 2.5], opacity: [0.5, 0] }}
        transition={{ duration: 2, repeat: Infinity, ease: "easeOut", delay: 1 }}
        className="absolute w-24 h-24 border border-cyan-500/50 rounded-full"
        style={{ willChange: 'transform, opacity' }}
      />
    </div>
  );
}

function PerformanceAnimation() {
  return (
    <div className="absolute inset-0 pt-20 flex flex-col justify-end opacity-20 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none z-0">
      <div className="absolute top-24 left-8 flex flex-col gap-1.5 font-mono text-xs text-cyan-400/80">
        <div className="flex items-center gap-2">
          <div className="w-1.5 h-1.5 rounded-full bg-red-400 animate-pulse shadow-[0_0_8px_rgba(248,113,113,0.8)]"></div>
          CPU 42%
        </div>
        <div className="flex items-center gap-2 text-green-400">
          <div className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse shadow-[0_0_8px_rgba(74,222,128,0.8)]"></div>
          RAM 7.2GB <span className="text-[10px] text-green-400/50 line-through ml-1">11.4GB</span>
        </div>
      </div>
      
      <div className="relative h-40 w-full flex items-end justify-between px-4 gap-1.5 border-b border-cyan-500/20">
        <div className="absolute inset-0 bg-gradient-to-t from-cyan-500/10 to-transparent"></div>
        {/* Dynamic Telemetry Bars Optimized with ScaleY */}
        {[...Array(14)].map((_, i) => {
          const baseScale = 0.3 + (Math.sin(i * 0.5) * 0.2); 
          return (
            <motion.div
              key={i}
              animate={{ 
                scaleY: [
                  baseScale, 
                  Math.max(0.1, baseScale + ((Math.sin(i * 42) * 0.5 + 0.5) * 0.4 - 0.2)), 
                  baseScale
                ] 
              }}
              transition={{ duration: 2 + (Math.sin(i * 15) * 0.5 + 0.5), repeat: Infinity, ease: "easeInOut" }}
              className={cn(
                "w-full h-full rounded-t-sm relative z-10 origin-bottom",
                i > 10 ? "bg-gradient-to-t from-green-500 to-green-400/50 shadow-[0_0_10px_rgba(74,222,128,0.3)]" : "bg-gradient-to-t from-cyan-500 to-cyan-400/50"
              )}
              style={{ willChange: 'transform' }}
            />
          );
        })}
      </div>
    </div>
  );
}

function DiagnosticsAnimation() {
  return (
    <div className="absolute right-0 top-0 bottom-0 w-1/3 bg-black/40 border-l border-white/5 px-4 overflow-hidden opacity-30 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
      <motion.div 
        animate={{ y: ["0%", "-50%"] }} 
        transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
        className="w-full relative py-4"
        style={{ willChange: 'transform' }}
      >
        {/* Render the identical list twice for a seamless infinite scroll loop */}
        {[0, 1].map((listIndex) => (
          <div key={listIndex} className="space-y-4 pb-4">
            {[1, 2, 3, 4, 5, 6].map(i => (
              <div key={i} className="w-full h-12 rounded-lg bg-white/5 border border-white/10 flex items-center px-3 gap-3 shadow-[0_0_15px_rgba(0,0,0,0.5)]">
                <div className={cn(
                  "w-2.5 h-2.5 rounded-full shadow-[0_0_8px_currentColor]", 
                  i % 2 === 0 ? "bg-green-400 text-green-400" : (i % 3 === 0 ? "bg-purple-400 text-purple-400" : "bg-cyan-400 text-cyan-400")
                )}></div>
                <div className="flex-1 space-y-2">
                  <div className="h-1.5 w-full bg-white/20 rounded-full"></div>
                  <div className="h-1.5 w-2/3 bg-white/10 rounded-full"></div>
                </div>
              </div>
            ))}
          </div>
        ))}
      </motion.div>
    </div>
  );
}

function CleanAnimation() {
  return (
    <div className="absolute inset-0 flex items-center justify-center opacity-10 group-hover:opacity-100 transition-opacity duration-500 z-0">
      <motion.div 
        animate={{ rotate: 360 }}
        transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
        className="w-48 h-48 rounded-full border-t-2 border-r-2 border-green-400 shadow-[0_0_30px_rgba(74,222,128,0.2)]"
        style={{ willChange: 'transform' }}
      />
      <div className="absolute text-green-400 font-mono font-bold text-xl drop-shadow-[0_0_10px_rgba(74,222,128,0.8)]">
        150+
      </div>
    </div>
  );
}

// ----------------------------------------
// Card Component
// ----------------------------------------

function BentoCard({ title, children, className, delay = 0, animation: Animation }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] }}
      className={cn(
        "bento-card group relative overflow-hidden bg-black/60 border border-white/10 backdrop-blur-xl rounded-[2rem]",
        className
      )}
    >
      {/* Background Interactive Glow */}
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700 bg-[radial-gradient(circle_at_center,rgba(34,211,238,0.08)_0%,transparent_60%)] -z-10 mix-blend-screen" />
      
      {/* Optional Custom Animation Component */}
      {Animation && <Animation />}

      <div className="relative z-10 p-8 h-full flex flex-col pointer-events-none">
        <div className="flex items-center gap-4 mb-5">
          <h3 className="font-bold text-white/90 text-xl tracking-tight group-hover:text-white transition-colors drop-shadow-[0_0_5px_rgba(255,255,255,0.2)]">{title}</h3>
        </div>
        <div className="text-muted leading-relaxed text-sm lg:text-base flex-grow group-hover:text-white/80 transition-colors pointer-events-auto">
          {children}
        </div>
      </div>
    </motion.div>
  );
}

// ----------------------------------------
// Main Bento Grid Layout (5-Card Asymmetric)
// ----------------------------------------

export function BentoGrid() {
  return (
    <section className="mb-40 relative z-10 max-w-7xl mx-auto">
      <div className="flex items-center gap-4 mb-12 px-2">
        <h2 className="text-3xl font-bold tracking-tight drop-shadow-[0_2px_10px_rgba(255,255,255,0.1)]">Capabilities</h2>
        <div className="h-[1px] flex-grow bg-gradient-to-r from-white/10 to-transparent"></div>
      </div>

      {/* Modern 4-Column Grid for exactly 5 uneven items */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 auto-rows-auto">
        
        {/* 1. Automation (Wide: Spans 2 cols) */}
        <BentoCard 
          delay={0.1} 
          title="1-Click Automation" 
          icon={PlayCircle} 
          className="md:col-span-2"
          animation={AutomationAnimation}
        >
          <div className="max-w-xs xl:max-w-sm">
            <p className="mb-4">The master 8-step pipeline automates optimization. Simply run the script, and it handles everything sequentially with built-in safety checks.</p>
            <div className="flex items-center gap-2 text-cyan-400 text-xs font-mono bg-cyan-400/10 border border-cyan-400/20 px-3 py-1.5 rounded-full inline-flex">
              <Power className="w-3 h-3" /> Zero Manual Configuration
            </div>
          </div>
        </BentoCard>

        {/* 2. Privacy (Square: Spans 1 col) */}
        <BentoCard 
          delay={0.2} 
          title="Privacy Shield" 
          icon={Shield} 
          className="md:col-span-1"
          animation={PrivacyAnimation}
        >
          <p className="relative z-10 text-center mt-4">15+ registry lockdowns. Defeats telemetry, locks down location, and blocks invasive ID tracking instantly.</p>
        </BentoCard>

        {/* 3. Performance (Tall: Spans 1 col, 2 rows) */}
        <BentoCard 
          delay={0.3} 
          title="Performance" 
          icon={Zap} 
          className="md:col-span-1 md:row-span-2 flex flex-col"
          animation={PerformanceAnimation}
        >
          <p className="relative z-10">Advanced RAM trimming, TCP/IP rest & auto-tuning, and dynamic power plan configuration.</p>
        </BentoCard>

        {/* 4. Diagnostics (Wide: Spans 2 cols) */}
        <BentoCard 
          delay={0.4} 
          title="Diagnostics" 
          icon={Activity} 
          className="md:col-span-2 relative"
          animation={DiagnosticsAnimation}
        >
          <div className="max-w-xs xl:max-w-sm">
            <p className="mb-6">Generates a stunning 10-section HTML System Health dashboard right in your browser. Analyzes your storage space, checks Heavy RAM processes, and pulls raw S.M.A.R.T. health data directly from your drives.</p>
            <button className="text-cyan-400 text-sm font-semibold flex items-center gap-1 hover:text-cyan-300 transition-colors drop-shadow-[0_0_5px_rgba(34,211,238,0.3)]">
              View Sample HTML Report <ChevronRight className="w-4 h-4 ml-1" />
            </button>
          </div>
        </BentoCard>

        {/* 5. Deep Cleaning (Square: Spans 1 col) */}
        <BentoCard 
          delay={0.5} 
          title="Deep Cleaning" 
          icon={Laptop} 
          className="md:col-span-1"
          animation={CleanAnimation}
        >
          <p className="relative z-10 text-center mt-2">Obliterates gigabytes of stale cache, Temp files, and scans/removes over 150 known OEM bloatware apps.</p>
        </BentoCard>

      </div>
    </section>
  );
}
