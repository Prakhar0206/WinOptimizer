import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Download, Github } from 'lucide-react';
import { MagneticButton } from '../components/ui/MagneticButton';
import { HeroTerminal } from '../components/home/HeroTerminal';
import { BentoGrid } from '../components/home/BentoGrid';
import { SafetyGuarantee } from '../components/home/SafetyGuarantee';
import { GuideSection } from '../components/home/GuideSection';

export function Home() {
  const navigate = useNavigate();

  const handleDownloadAndRedirect = (e) => {
    e.preventDefault();
    // Trigger download
    const link = document.createElement("a");
    link.href = "https://github.com/Prakhar0206/WinOptimizer/archive/refs/heads/main.zip";
    link.download = "WinOptimizer-Main.zip";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    // Frictionless Handoff to Donate
    setTimeout(() => {
      navigate('/donate');
      window.scrollTo(0,0);
    }, 500); 
  };

  return (
    <main className="flex-grow pb-24 pt-32 px-6">
      <div className="max-w-7xl mx-auto tracking-tight">
        
        {/* HERO SECTION */}
        <section className="text-center space-y-8 mb-40 relative z-10">
          <motion.div 
            initial={{ opacity: 0, scale: 0.95, filter: "blur(10px)" }}
            animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
            transition={{ duration: 1, ease: "easeOut" }}
          >
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-sm font-medium text-cyan-400 mb-10 backdrop-blur-md shadow-[0_0_20px_rgba(34,211,238,0.1)]">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-cyan-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-cyan-500 shadow-[0_0_8px_rgba(34,211,238,1)]"></span>
              </span>
              v4.0 Released — Cleaner, Faster, Safer.
            </div>
            
            <h1 className="text-5xl md:text-7xl lg:text-8xl font-extrabold tracking-tighter text-transparent bg-clip-text bg-gradient-to-b from-white via-white to-white/30 mb-8 drop-shadow-[0_0_40px_rgba(255,255,255,0.2)] leading-[1.1]">
              The Windows Optimizer<br />You Can Actually Trust.
            </h1>
            
            <p className="text-lg md:text-xl text-muted/70 max-w-2xl mx-auto font-medium leading-relaxed drop-shadow-md">
              20 powerful tools. Zero telemetry. One script. Safely debloat, repair, and accelerate Windows 10 & 11 in minutes.
            </p>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.8 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-6 pt-6 relative group"
          >
            {/* Magnetic Glow behind buttons */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-32 bg-cyan-500/20 blur-[60px] rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none"></div>

            <MagneticButton 
              onClick={handleDownloadAndRedirect}
              className="bg-cyan-400 hover:bg-cyan-300 text-black px-10 py-4 rounded-2xl font-bold text-lg flex items-center gap-3 w-full sm:w-auto justify-center shadow-[0_0_40px_rgba(34,211,238,0.25)] hover:shadow-[0_0_80px_rgba(34,211,238,0.5)] transition-shadow duration-500 z-10"
            >
              <Download className="w-5 h-5 pointer-events-none" />
              Download v4.0 (.zip)
            </MagneticButton>
            
            <MagneticButton 
              href="https://github.com/Prakhar0206/WinOptimizer"
              className="bg-white/5 hover:bg-white/10 border border-white/10 text-white px-10 py-4 rounded-2xl font-semibold text-lg flex items-center gap-3 w-full sm:w-auto justify-center backdrop-blur-md z-10 transition-colors"
            >
              <Github className="w-5 h-5 pointer-events-none" />
              View on GitHub
            </MagneticButton>
          </motion.div>

          <HeroTerminal />
        </section>

        <BentoGrid />
        <SafetyGuarantee />
        <GuideSection />
        
      </div>
    </main>
  );
}
