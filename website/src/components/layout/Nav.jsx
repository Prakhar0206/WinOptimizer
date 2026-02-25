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
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={cn(
      "fixed top-0 w-full z-50 transition-all duration-300 border-b border-transparent",
      scrolled && "bg-background/80 backdrop-blur-md border-white/5 shadow-lg"
    )}>
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 text-cyan-400 font-mono font-bold text-xl hover:text-cyan-300 transition-colors">
          <TerminalSquare className="w-5 h-5" />
          <span>WinOptimizer_</span>
        </Link>
        <div className="flex items-center gap-4">
          <a href="https://github.com/Prakhar0206/WinOptimizer" target="_blank" rel="noreferrer" className="text-muted hover:text-white transition-colors flex items-center gap-2 text-sm font-medium">
            <Github className="w-4 h-4" />
            <span className="hidden sm:inline">Star{stars !== null ? `s (${stars})` : ''}</span>
          </a>
          <motion.button 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: scrolled ? 1 : 0, scale: scrolled ? 1 : 0.9 }}
            onClick={onStartDownload}
            className="bg-cyan-400 hover:bg-cyan-300 text-black px-4 py-1.5 rounded-full font-semibold text-sm transition-colors flex items-center gap-2 pointer-events-auto shadow-sm"
            style={{ pointerEvents: scrolled ? 'auto' : 'none' }}
          >
            <Download className="w-4 h-4" /> Download
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
            <Link to="/" className="flex items-center gap-2 bg-white/10 backdrop-blur-lg border border-white/10 hover:border-cyan-400/50 hover:bg-white/15 text-white/90 px-5 py-3 rounded-full shadow-2xl transition-all duration-300 hover:-translate-y-1">
              <ArrowLeft className="w-4 h-4 text-cyan-400" />
              <span className="text-sm font-semibold tracking-wide">Back to Home</span>
            </Link>
          ) : (
            <Link to="/donate" className="flex items-center gap-2 bg-white/10 backdrop-blur-lg border border-white/10 hover:border-cyan-400/50 hover:bg-white/15 text-white/90 px-5 py-3 rounded-full shadow-2xl transition-all duration-300 hover:-translate-y-1">
              <Heart className="w-4 h-4 text-pink-400 fill-pink-400/20" />
              <span className="text-sm font-semibold tracking-wide">Support Project</span>
            </Link>
          )}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
