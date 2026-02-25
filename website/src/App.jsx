import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Nav, FAB } from './components/layout/Nav';
import { Footer } from './components/layout/Footer';
import { Home } from './pages/Home';
import { Donate } from './pages/Donate';
import { useGithubMetadata } from './hooks/useGithubMetadata';
import { useNavigate } from 'react-router-dom';

function Layout() {
  const { stars } = useGithubMetadata();
  const navigate = useNavigate();

  const handleStartDownload = () => {
    // Hidden anchor download
    const link = document.createElement("a");
    link.href = "https://github.com/Prakhar0206/WinOptimizer/archive/refs/heads/main.zip";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Redirect to donate route
    setTimeout(() => {
      navigate('/donate');
      window.scrollTo(0,0);
    }, 500);
  };

  return (
    <div className="min-h-screen bg-black text-white font-sans antialiased overflow-x-hidden relative selection:bg-cyan-400/30 selection:text-cyan-50">
      {/* Massive subtle background glows for Nocturnal Noir deep contrast without expensive CSS blur filters */}
      <div className="fixed top-[-20%] left-[-10%] w-[50vw] h-[50vw] bg-[radial-gradient(circle,rgba(34,211,238,0.02)_0%,transparent_60%)] pointer-events-none -z-20 mix-blend-screen" style={{ willChange: 'transform' }}></div>
      <div className="fixed bottom-[-20%] right-[-10%] w-[60vw] h-[60vw] bg-[radial-gradient(circle,rgba(168,85,247,0.02)_0%,transparent_60%)] pointer-events-none -z-20 mix-blend-screen" style={{ willChange: 'transform' }}></div>

      <Nav stars={stars} onStartDownload={handleStartDownload} />
      
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/donate" element={<Donate />} />
      </Routes>
      
      <FAB />
      <Footer />
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Layout />
    </BrowserRouter>
  );
}

export default App;
