import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useLocation } from 'react-router-dom';
import { Download, Github, TerminalSquare, Heart, ArrowLeft } from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

// Utility for class merging
function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export function Nav({ stars, onStartDownload }) {
  const location = useLocation();
  const [scrolled, setScrolled] = useState(false);
  const [hoveredLink, setHoveredLink] = useState(null);

  const links = [
    { name: 'Features', id: 'features', href: '#features' },
    { name: 'Guide', id: 'guide', href: '#guide' },
    { name: 'Safety', id: 'safety', href: '#safety' },
  ];

  // Custom smooth scroll with requestAnimationFrame for guaranteed animation
  const smoothScrollTo = (targetY, duration = 800) => {
    const startY = window.scrollY;
    const diff = targetY - startY;
    let startTime = null;

    const easeInOutCubic = (t) => t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;

    const step = (timestamp) => {
      if (!startTime) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = easeInOutCubic(progress);
      window.scrollTo(0, startY + diff * eased);
      if (progress < 1) {
        requestAnimationFrame(step);
      }
    };

    requestAnimationFrame(step);
  };

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={cn(
      "fixed top-0 w-full z-50 transition-all duration-500 border-b border-transparent",
      scrolled && "bg-[#050505]/70 backdrop-blur-xl border-cyan-500/20 shadow-[0_4px_30px_rgba(34,211,238,0.05)]"
    )}>
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        
        {/* Brand */}
        <Link to="/" className="flex items-center gap-2 group relative">
          <div className="absolute -inset-2 bg-gradient-to-r from-cyan-500 to-emerald-500 rounded-lg blur opacity-0 group-hover:opacity-20 transition duration-500"></div>
          <TerminalSquare className="w-5 h-5 text-cyan-400 group-hover:text-cyan-300 transition-colors drop-shadow-[0_0_8px_rgba(34,211,238,0.5)]" />
          <span className="text-white font-mono font-bold text-lg tracking-tight">WinOptimizer_</span>
        </Link>
        
        {/* Nav Links (Desktop) - only on home page */}
        {location.pathname === '/' && (
        <nav className="hidden md:flex items-center gap-1 bg-white/5 rounded-full px-2 py-1 border border-white/5" onMouseLeave={() => setHoveredLink(null)}>
          {links.map((link) => (
             <a
               key={link.id}
               href={link.href}
               onMouseEnter={() => setHoveredLink(link.id)}
               onClick={(e) => {
                 e.preventDefault();
                 const el = document.querySelector(link.href);
                 if (el) {
                   const y = el.getBoundingClientRect().top + window.scrollY - 100;
                   smoothScrollTo(y, 900);
                 }
               }}
               className="relative px-4 py-1.5 text-sm font-medium text-white/70 hover:text-white transition-colors"
             >
               {hoveredLink === link.id && (
                 <motion.div
                   layoutId="navHeaderBackground"
                   className="absolute inset-0 bg-white/10 rounded-full"
                   transition={{ type: 'spring', bounce: 0.2, duration: 0.6 }}
                 />
               )}
               <span className="relative z-10">{link.name}</span>
             </a>
          ))}
        </nav>
        )}

        {/* Actions */}
        <div className="flex items-center gap-4">
          <a 
            href="https://github.com/Prakhar0206/WinOptimizer" 
            target="_blank" 
            rel="noreferrer" 
            className="group flex items-center gap-2 bg-white/5 border border-white/10 hover:border-cyan-500/50 hover:bg-white/10 px-3 py-1.5 rounded-full text-sm font-medium text-white/80 transition-all duration-300 hover:shadow-[0_0_15px_rgba(34,211,238,0.15)]"
          >
            <Github className="w-4 h-4 text-white group-hover:text-cyan-400 transition-colors" />
            <span className="hidden sm:inline">Star{stars !== null ? `s (${stars})` : ''}</span>
          </a>
          
          <motion.button 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: scrolled ? 1 : 0, scale: scrolled ? 1 : 0.9 }}
            onClick={onStartDownload}
            className="group relative overflow-hidden bg-gradient-to-r from-cyan-500 to-emerald-500 text-black px-5 py-1.5 rounded-full font-bold text-sm transition-all duration-300 flex items-center gap-2 pointer-events-auto shadow-[0_0_20px_rgba(34,211,238,0.3)] hover:shadow-[0_0_25px_rgba(34,211,238,0.4)] hover:-translate-y-0.5"
            style={{ pointerEvents: scrolled ? 'auto' : 'none' }}
          >
            {/* Shimmer effect */}
            <div className="absolute inset-0 -translate-x-full animate-[shimmer_2s_infinite] bg-gradient-to-r from-transparent via-white/40 to-transparent skew-x-12" />
            <Download className="w-4 h-4 group-hover:animate-bounce relative z-10" /> 
            <span className="relative z-10">Download</span>
          </motion.button>
        </div>
      </div>
    </header>
  );
}

export function FAB() {
  const [scrolled, setScrolled] = useState(false);
  const location = useLocation();
  const isDonatePage = location.pathname === '/donate';

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 300);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <AnimatePresence>
      {(scrolled || isDonatePage) && (
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.8 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.8 }}
          className="fixed bottom-6 right-6 z-40 hidden sm:block"
        >
          {isDonatePage ? (
            <Link to="/" className="group flex items-center gap-2 bg-[#050505]/80 backdrop-blur-xl border border-white/10 hover:border-cyan-400/50 hover:bg-white/10 text-white/90 px-5 py-3 rounded-full shadow-2xl transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(34,211,238,0.15)]">
              <ArrowLeft className="w-4 h-4 text-cyan-400 group-hover:-translate-x-1 transition-transform" />
              <span className="text-sm font-semibold tracking-wide">Back to Home</span>
            </Link>
          ) : (
            <Link to="/donate" className="group flex items-center gap-2 bg-[#050505]/80 backdrop-blur-xl border border-white/10 hover:border-pink-500/50 hover:bg-white/10 text-white/90 px-5 py-3 rounded-full shadow-2xl transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(244,114,182,0.15)]">
              <Heart className="w-4 h-4 text-pink-500 fill-pink-500/20 group-hover:scale-110 transition-transform" />
              <span className="text-sm font-semibold tracking-wide group-hover:text-pink-100 transition-colors">Support Project</span>
            </Link>
          )}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
