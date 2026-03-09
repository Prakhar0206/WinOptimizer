import React, { useEffect, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { TerminalSquare, Instagram, ArrowUp, Mail, Linkedin, X, Github, Heart } from "lucide-react";

export function Footer() {
    const location = useLocation();
    const [isModalOpen, setIsModalOpen] = useState(false);

    useEffect(() => {
        const observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add("is-visible");
                        observer.unobserve(entry.target);
                    }
                });
            },
            { threshold: 0.1 }
        );

        const elements = document.querySelectorAll(".animate-on-scroll");
        elements.forEach((el) => observer.observe(el));

        return () => observer.disconnect();
    }, []);

    useEffect(() => {
        if (isModalOpen) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'unset';
        }
        return () => {
            document.body.style.overflow = 'unset';
        };
    }, [isModalOpen]);

    const handleModalOpen = (e) => {
        e.preventDefault();
        setIsModalOpen(true);
    }

    const handleModalClose = () => {
        setIsModalOpen(false);
    }

    const scrollToTop = (e) => {
        e.preventDefault();
        const startY = window.scrollY;
        const duration = 900;
        let startTime = null;
        const easeInOutCubic = (t) => t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
        const step = (timestamp) => {
            if (!startTime) startTime = timestamp;
            const progress = Math.min((timestamp - startTime) / duration, 1);
            window.scrollTo(0, startY * (1 - easeInOutCubic(progress)));
            if (progress < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
    }

    if (location.pathname === '/donate') {
        return null;
    }

    return (
        <>
            <style>{`
        .animate-on-scroll { 

            opacity: 0; 
            transform: translateY(30px); 
        }
        .animate-on-scroll.is-visible {
            opacity: 1;
            transform: translateY(0);
            transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1), 
                        transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        .footer-link {
            position: relative;
            display: inline-block;
            transition: color 0.3s ease;
        }
        .footer-link::after {
            content: '';
            position: absolute;
            width: 100%;
            transform: scaleX(0);
            height: 2px;
            bottom: -4px;
            left: 0;
            background: linear-gradient(90deg, #22d3ee, #10b981);
            transform-origin: bottom right;
            transition: transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            border-radius: 2px;
        }
        .footer-link:hover {
            color: #22d3ee;
        }
        .footer-link:hover::after {
            transform: scaleX(1);
            transform-origin: bottom left;
        }
        
        .social-icon {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .social-icon:hover {
            transform: scale(1.15) rotate(-5deg);
            box-shadow: 0 8px 25px -8px currentColor;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
        .animate-float {
            animation: float 4s ease-in-out infinite;
        }
        
        .modal-overlay {
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .modal-content {
            animation: slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        @keyframes slideUp {
            from { 
                opacity: 0;
                transform: scale(0.9) translateY(20px);
            }
            to { 
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }
        
        .cta-button-footer {
            position: relative;
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .cta-button-footer::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }
        .cta-button-footer:hover::before {
            width: 300px;
            height: 300px;
        }
        .cta-button-footer:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px -10px rgba(34, 211, 238, 0.5);
        }
        
        .back-to-top-circle {
            transition: all 0.3s ease;
        }
        .back-to-top-btn:hover .back-to-top-circle {
            background: linear-gradient(135deg, #22d3ee, #10b981);
            border-color: transparent;
            color: black;
        }
        
        .contact-item {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .contact-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: linear-gradient(180deg, #22d3ee, #10b981);
            transform: scaleY(0);
            transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .contact-item::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(34, 211, 238, 0.05), rgba(16, 185, 129, 0.05));
            opacity: 0;
            transition: opacity 0.4s ease;
        }
        .contact-item:hover::before {
            transform: scaleY(1);
        }
        .contact-item:hover::after {
            opacity: 1;
        }
        .contact-item:hover {
            transform: translateX(8px);
            box-shadow: 0 4px 20px -4px rgba(34, 211, 238, 0.15);
        }
        .contact-item-icon {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .contact-item:hover .contact-item-icon {
            transform: scale(1.2) rotate(5deg);
        }
        
        .shine-effect {
            position: relative;
            overflow: hidden;
        }
        .shine-effect::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(34, 211, 238, 0.2), transparent);
            transition: left 0.5s;
        }
        .shine-effect:hover::before {
            left: 100%;
        }
        
        @keyframes heartbeat {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.25); }
        }
        .heart-beat {
            animation: heartbeat 1.5s ease-in-out infinite;
            display: inline-block;
        }
      `}</style>

            <footer className="bg-gradient-to-br from-[#020202] via-[#050505] to-[#011424] text-white/70 py-16 px-6 relative overflow-hidden transition-colors duration-200 border-t border-white/5">
                {/* Background Effects */}
                <div className="absolute inset-0 opacity-[0.03]" style={{
                    backgroundImage: 'radial-gradient(circle at 2px 2px, white 1px, transparent 0)',
                    backgroundSize: '40px 40px'
                }} />
                <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none" />
                <div className="absolute -top-40 -right-40 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none" />

                <div className="max-w-7xl mx-auto relative z-10 animate-on-scroll">
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-12 text-center md:text-left">
                        {/* Column 1: Brand */}
                        <div className="md:col-span-2">
                            <div className="flex items-center justify-center md:justify-start gap-3 mb-4">
                                <TerminalSquare className="h-8 w-8 text-cyan-400 animate-float" />
                                <h3 className="text-2xl font-bold font-mono tracking-tight text-white/90">WinOptimizer_</h3>
                            </div>
                            <p className="text-white/60 max-w-md mx-auto md:mx-0 leading-relaxed mb-6">
                                The ultimate, open-source Windows optimization master-script. Eliminate telemetry, trim background bloat, and restore your system's peak performance in one click.
                            </p>
                            <div className="mt-8 flex flex-col sm:flex-row items-center justify-center md:justify-start gap-4">
                                <a href="https://github.com/Prakhar0206/WinOptimizer/issues"
                                    target="_blank" rel="noreferrer"
                                    className="cta-button-footer w-full sm:w-auto text-center inline-block bg-gradient-to-r from-cyan-500 to-emerald-500 text-black font-bold py-3 px-8 rounded-full shadow-lg relative">
                                    <span className="relative z-10">Report an Issue</span>
                                </a>
                                <a href="https://github.com/Prakhar0206/WinOptimizer"
                                    target="_blank" rel="noreferrer"
                                    className="w-full sm:w-auto text-center inline-flex items-center justify-center gap-2 bg-white/5 border border-white/10 hover:border-cyan-400 hover:bg-white/10 text-white font-bold py-3 px-8 rounded-full shadow-lg transition-all duration-300">
                                    <Github className="w-4 h-4" />
                                    Star the Repo
                                </a>
                            </div>
                        </div>

                        {/* Column 2: Quick Links */}
                        <div>
                            <h4 className="text-lg font-semibold text-white/90 mb-6 tracking-wide drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]">Project Links</h4>
                            <ul className="space-y-4 text-white/60">
                                <li>
                                    <a href="https://github.com/Prakhar0206/WinOptimizer" target="_blank" rel="noreferrer"
                                        className="footer-link inline-block font-medium">
                                        Source Code
                                    </a>
                                </li>
                                <li>
                                    <a href="https://github.com/Prakhar0206/WinOptimizer/blob/main/README.md" target="_blank" rel="noreferrer"
                                        className="footer-link inline-block font-medium">
                                        Documentation
                                    </a>
                                </li>
                                <li>
                                    <Link to="/donate"
                                        className="footer-link inline-block font-medium">
                                        Support the Project
                                    </Link>
                                </li>
                                <li>
                                    <span className="inline-block font-medium px-2 py-0.5 rounded text-xs border border-white/10 bg-white/5 mt-2">
                                        MIT License
                                    </span>
                                </li>
                            </ul>
                        </div>

                        {/* Column 3: Connect */}
                        <div>
                            <h4 className="text-lg font-semibold text-white/90 mb-6 tracking-wide drop-shadow-[0_0_8px_rgba(255,255,255,0.2)]">Creator</h4>
                            <div className="flex justify-center md:justify-start gap-4 flex-wrap">
                                <a href="https://github.com/Prakhar0206"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="w-12 h-12 rounded-full bg-white/5 border border-white/10 backdrop-blur-sm flex items-center justify-center text-white/80 social-icon shadow-sm hover:text-white hover:border-cyan-400 hover:bg-white/10">
                                    <Github size={20} />
                                </a>
                                <a href="https://www.linkedin.com/in/prakharaggarwal-dev"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="w-12 h-12 rounded-full bg-white/5 border border-white/10 backdrop-blur-sm flex items-center justify-center text-white/80 social-icon shadow-sm hover:text-[#0a66c2] hover:border-[#0a66c2] hover:bg-white/10">
                                    <Linkedin size={20} />
                                </a>
                                <a href="https://www.instagram.com/_prakharaggarwal/"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="w-12 h-12 rounded-full bg-white/5 border border-white/10 backdrop-blur-sm flex items-center justify-center text-white/80 social-icon shadow-sm hover:text-rose-500 hover:border-rose-500 hover:bg-white/10">
                                    <Instagram size={20} />
                                </a>
                            </div>
                            <p className="mt-6 text-sm text-white/40 flex items-center justify-center md:justify-start gap-1.5">
                                Made with <span className="text-rose-500 heart-beat"><Heart className="w-4 h-4 fill-rose-500" /></span> for extreme performance
                            </p>
                        </div>
                    </div>

                    {/* Bottom Bar */}
                    <div className="mt-16 pt-8 border-t border-white/10 flex flex-col md:flex-row items-center gap-y-4">
                        <div className="w-full md:w-1/3 text-center md:text-left">
                            <p className="text-sm text-white/50">
                                &copy; {new Date().getFullYear()} WinOptimizer. All rights reserved.
                            </p>
                        </div>
                        <div className="w-full md:w-1/3 text-center">
                            <div className="text-xs text-white/50">
                                Crafted with care by{' '}
                                <button onClick={handleModalOpen}
                                    className="font-semibold text-white/80 hover:text-cyan-400 transition-colors underline decoration-white/20 hover:decoration-cyan-400 underline-offset-4">
                                    Prakhar Aggarwal
                                </button>
                            </div>
                        </div>
                        <div className="w-full md:w-1/3 flex justify-center md:justify-end">
                            <button onClick={scrollToTop}
                                className="back-to-top-btn group flex items-center gap-3 text-sm text-white/60 hover:text-white transition-colors font-medium">
                                <span>Back to Top</span>
                                <span className="back-to-top-circle p-2.5 rounded-full bg-white/5 border border-white/10 group-hover:text-black transition-all shadow-sm">
                                    <ArrowUp className="h-4 w-4" />
                                </span>
                            </button>
                        </div>
                    </div>
                </div>
            </footer>

            {/* Contact Modal */}
            {isModalOpen && (
                <div
                    className="modal-overlay fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4"
                    onClick={handleModalClose}
                >
                    <div
                        className="modal-content bg-[#0a0a0a] border border-white/10 rounded-3xl shadow-[0_0_50px_rgba(34,211,238,0.1)] p-8 max-w-md w-full relative overflow-hidden"
                        onClick={(e) => e.stopPropagation()}
                    >
                        {/* Modal Background Glow */}
                        <div className="absolute top-0 right-0 w-32 h-32 bg-cyan-500/20 blur-3xl rounded-full" />
                        <div className="absolute bottom-0 left-0 w-32 h-32 bg-purple-500/20 blur-3xl rounded-full" />

                        {/* Close Button */}
                        <button
                            onClick={handleModalClose}
                            className="absolute top-4 right-4 text-white/40 hover:text-white hover:rotate-90 hover:scale-110 transition-all duration-300 p-1 z-10 bg-white/5 rounded-full hover:bg-white/10">
                            <X size={20} />
                        </button>

                        {/* Header */}
                        <div className="text-center mb-6 relative z-10 pt-2">
                            <h3 className="text-3xl font-bold bg-gradient-to-r from-cyan-400 to-emerald-400 bg-clip-text text-transparent mb-2">Prakhar Aggarwal</h3>
                            <p className="text-white/60 font-medium tracking-wide">Software Engineer & Designer</p>
                        </div>

                        {/* CTA Box */}
                        <div className="shine-effect text-center text-sm text-white/80 mb-6 p-4 bg-gradient-to-r from-cyan-500/10 to-emerald-500/10 rounded-xl border border-cyan-500/20 relative z-10 shadow-inner">
                            <p className="font-medium">Need robust software or a stunning web app?</p>
                            <p className="text-white/50 mt-1">Let's build something exceptional!</p>
                        </div>

                        {/* Contact Links */}
                        <div className="space-y-3 relative z-10">
                            <a href="https://www.instagram.com/_prakharaggarwal/"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="contact-item flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/10 hover:border-white/20">
                                <div className="contact-item-icon bg-white/5 p-2 rounded-lg text-rose-400 shadow-[0_0_10px_rgba(244,63,94,0.2)]">
                                    <Instagram size={20} />
                                </div>
                                <span className="font-medium text-white/80 tracking-wide">_prakharaggarwal</span>
                            </a>

                            <a href="https://www.linkedin.com/in/prakharaggarwal-dev"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="contact-item flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/10 hover:border-white/20">
                                <div className="contact-item-icon bg-white/5 p-2 rounded-lg text-[#0a66c2] shadow-[0_0_10px_rgba(10,102,194,0.2)]">
                                    <Linkedin size={20} />
                                </div>
                                <span className="font-medium text-white/80 tracking-wide">prakharaggarwal-dev</span>
                            </a>

                            <a href="mailto:aprakhar32@gmail.com"
                                className="contact-item flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/10 hover:border-white/20">
                                <div className="contact-item-icon bg-white/5 p-2 rounded-lg text-cyan-400 shadow-[0_0_10px_rgba(34,211,238,0.2)]">
                                    <Mail size={20} />
                                </div>
                                <span className="font-medium text-white/80 tracking-wide">aprakhar32@gmail.com</span>
                            </a>
                        </div>
                    </div>
                </div>
            )}
        </>
    );
}
