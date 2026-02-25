import { useState } from 'react';
import { CheckCircle2, Copy } from 'lucide-react';

export function CopyableCode({ code }) {
  const [copied, setCopied] = useState(false);
  
  const copy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  
  return (
    <div className="relative group/copy">
      <div className="bg-black/50 border border-white/10 rounded-lg p-4 font-mono text-sm text-cyan-50 overflow-x-auto whitespace-pre">
        {code}
      </div>
      <button 
        onClick={copy} 
        className="absolute top-2 right-2 p-2 rounded-md bg-white/5 opacity-0 group-hover/copy:opacity-100 focus:opacity-100 hover:bg-white/10 transition-all border border-white/5"
        aria-label="Copy to clipboard"
      >
        {copied ? <CheckCircle2 className="w-4 h-4 text-green-400" /> : <Copy className="w-4 h-4 text-white/50" />}
      </button>
      {copied && (
        <div className="absolute top-[-30px] right-0 text-xs text-green-400 bg-white/10 px-2 py-1 rounded shadow drop-shadow-lg">
          Copied!
        </div>
      )}
    </div>
  );
}
