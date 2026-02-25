import { TerminalSquare, ChevronRight } from 'lucide-react';

export function Footer() {
  return (
    <footer className="border-t border-white/5 py-10 mt-auto px-6 relative z-10 bg-background/80 backdrop-blur-xl">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6">
        <div className="flex items-center gap-2">
          <TerminalSquare className="w-6 h-6 text-muted" />
          <span className="text-base text-white/80 font-bold font-mono tracking-tight">WinOptimizer_</span>
        </div>
        
        <div className="text-sm font-medium text-muted flex flex-wrap justify-center gap-x-8 gap-y-4">
          <span className="bg-white/5 px-2 py-0.5 rounded text-xs border border-white/5">MIT License</span>
          <a href="https://github.com/Prakhar0206/WinOptimizer" className="hover:text-cyan-400 transition-colors">Source Code</a>
          <a href="https://github.com/Prakhar0206/WinOptimizer/issues" className="hover:text-cyan-400 transition-colors">Bug Tracking</a>
          <a href="https://github.com/Prakhar0206" className="hover:text-cyan-400 transition-colors">Developer Github</a>
          <a href="https://www.linkedin.com/in/prakharaggarwal-dev" target="_blank" rel="noreferrer" className="hover:text-cyan-400 transition-colors flex items-center gap-1">LinkedIn <ChevronRight className="w-3 h-3 opacity-50" /></a>
          <a href="mailto:aprakhar32@gmail.com" className="hover:text-cyan-400 transition-colors flex items-center gap-1">Email <ChevronRight className="w-3 h-3 opacity-50" /></a>
        </div>

        <div className="text-sm text-muted">
          Built by <a href="https://github.com/Prakhar0206" target="_blank" rel="noreferrer" className="text-white hover:text-cyan-400 transition-colors font-semibold">Prakhar Aggarwal</a>
        </div>
      </div>
    </footer>
  );
}
