import { useEffect, useRef } from 'react';
import { Coffee, ScanLine, Info } from 'lucide-react';

export function Donate() {
  const qrRef = useRef(null);
  const qrLoaded = useRef(false);

  useEffect(() => {
    if (qrLoaded.current) return;
    qrLoaded.current = true;

    const initQR = () => {
      if (!qrRef.current) return;
      qrRef.current.innerHTML = '';

      const QRCodeStyling = window.QRCodeStyling;
      const qr = new QRCodeStyling({
        width: 300,
        height: 300,
        type: "svg",
        qrOptions: { errorCorrectionLevel: "H" },
        data: "upi://pay?pa=prakharaggarwal@fam&pn=Prakhar Aggarwal",
        image: "https://upload.wikimedia.org/wikipedia/commons/e/e1/UPI-Logo-vector.svg",
        dotsOptions: { color: "#0f0f0f", type: "rounded" },
        backgroundOptions: { color: "#ffffff" },
        imageOptions: { crossOrigin: "anonymous", margin: 8, imageSize: 0.4 },
        cornersSquareOptions: { color: "#0f0f0f", type: "extra-rounded" },
        cornersDotOptions: { color: "#db2777", type: "dot" },
      });
      qr.append(qrRef.current);
    };

    if (window.QRCodeStyling) {
      initQR();
    } else {
      const script = document.createElement('script');
      script.src = 'https://unpkg.com/qr-code-styling@1.5.0/lib/qr-code-styling.js';
      script.onload = initQR;
      document.head.appendChild(script);
    }
  }, []);

  return (
    <>
      <style>{`
        @keyframes fadeInScale {
          from { opacity: 0; transform: scale(0.95) translateY(20px); filter: blur(10px); }
          to   { opacity: 1; transform: scale(1) translateY(0); filter: blur(0px); }
        }
        .donate-card { animation: fadeInScale 0.6s cubic-bezier(0.22, 1, 0.36, 1) forwards; }
        #qr-inner svg { display: block; width: 300px !important; height: 300px !important; }
      `}</style>

      <main className="flex-grow flex items-center justify-center pt-24 pb-12 px-6 relative z-10 min-h-[85vh]">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-lg h-96 bg-[radial-gradient(circle_at_center,rgba(244,114,182,0.15)_0%,transparent_70%)] blur-[80px] -z-10" />

        <div className="donate-card bento-card bg-black/80 backdrop-blur-2xl max-w-lg w-full text-center py-16 px-8 shadow-[0_0_80px_rgba(0,0,0,0.8)] border border-white/10 relative overflow-hidden rounded-[2rem]">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-pink-500 via-cyan-400 to-green-400 opacity-80" />

          <div className="w-20 h-20 mx-auto bg-gradient-to-b from-white/10 to-transparent border border-white/20 rounded-full flex items-center justify-center mb-8 shadow-[inset_0_-10px_20px_rgba(0,0,0,0.5)]">
            <Coffee className="w-10 h-10 text-pink-400 drop-shadow-[0_0_20px_rgba(244,114,182,0.6)]" />
          </div>

          <h1 className="text-3xl font-bold mb-4 text-white tracking-tight drop-shadow-md">Support the Project</h1>
          <p className="text-muted/80 mb-10 text-base leading-relaxed max-w-sm mx-auto">
            WinOptimizer is 100% free and open-source. If it revived your slow PC, consider buying me a coffee! Your support fuels future updates.
          </p>

          {/* QR Code */}
          <div className="relative mx-auto mb-6 inline-block group">
            <div className="bg-white rounded-2xl p-3 shadow-[0_0_50px_rgba(255,255,255,0.1)] hover:shadow-[0_0_60px_rgba(255,255,255,0.2)] hover:scale-[1.02] transition-all duration-500">
              <div className="absolute top-0 left-0 w-7 h-7 border-t-4 border-l-4 border-pink-500 rounded-tl-xl transition-transform group-hover:-translate-x-0.5 group-hover:-translate-y-0.5 z-10 pointer-events-none" />
              <div className="absolute top-0 right-0 w-7 h-7 border-t-4 border-r-4 border-pink-500 rounded-tr-xl transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5 z-10 pointer-events-none" />
              <div className="absolute bottom-0 left-0 w-7 h-7 border-b-4 border-l-4 border-pink-500 rounded-bl-xl transition-transform group-hover:-translate-x-0.5 group-hover:translate-y-0.5 z-10 pointer-events-none" />
              <div className="absolute bottom-0 right-0 w-7 h-7 border-b-4 border-r-4 border-pink-500 rounded-br-xl transition-transform group-hover:translate-x-0.5 group-hover:translate-y-0.5 z-10 pointer-events-none" />
              <div id="qr-inner" ref={qrRef} style={{ width: 300, height: 300, overflow: 'hidden', display: 'block' }} />
            </div>
          </div>

          {/* Scan prompt */}
          <div className="flex items-center justify-center gap-2 text-pink-400 mb-6">
            <ScanLine className="w-4 h-4" />
            <span className="text-sm font-semibold tracking-wide uppercase">Scan & pay any amount you'd like</span>
          </div>

          {/* UPI logo */}
          <div className="flex items-center justify-center mb-8 opacity-50 grayscale">
            <img src="https://upload.wikimedia.org/wikipedia/commons/e/e1/UPI-Logo-vector.svg" alt="UPI" className="h-4" />
          </div>

          {/* Note */}
          <div className="flex items-start gap-3 bg-white/5 border border-white/10 rounded-xl px-4 py-3.5 text-left max-w-sm mx-auto">
            <Info className="w-4 h-4 text-white/40 mt-0.5 shrink-0" />
            <p className="text-xs text-white/40 leading-relaxed">
              This page won't show any confirmation after you donate. Once your UPI app confirms the payment, your donation is done. Thank you so much to everyone who contributes! ♥
            </p>
          </div>
        </div>
      </main>
    </>
  );
}