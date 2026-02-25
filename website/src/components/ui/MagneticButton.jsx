import { useRef } from 'react';
import { motion, useMotionValue, useSpring, useMotionTemplate } from 'framer-motion';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export function MagneticButton({ children, className, onClick, href }) {
  const ref = useRef(null);

  // 3D Tilt parameters
  const rotateX = useMotionValue(0);
  const rotateY = useMotionValue(0);
  
  // Spotlight tracking
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  // Smooth, buttery physics
  const springConfig = { damping: 20, stiffness: 300, mass: 0.5 };
  const springRotateX = useSpring(rotateX, springConfig);
  const springRotateY = useSpring(rotateY, springConfig);

  const handleMouseMove = (e) => {
    if (!ref.current) return;
    const { clientX, clientY } = e;
    const { height, width, left, top } = ref.current.getBoundingClientRect();
    
    // Calculate distance from center (-1 to 1)
    const xPos = (clientX - left) / width - 0.5;
    const yPos = (clientY - top) / height - 0.5;

    // Set a very subtle tilt (max 8 degrees)
    const maxTilt = 8;
    rotateX.set(yPos * -maxTilt * 2); 
    rotateY.set(xPos * maxTilt * 2);

    // Spotlight exact cursor position
    mouseX.set(clientX - left);
    mouseY.set(clientY - top);
  };

  const handleMouseLeave = () => {
    rotateX.set(0);
    rotateY.set(0);
  };

  const Component = href ? motion.a : motion.button;

  return (
    <Component
      ref={ref}
      href={href}
      onClick={onClick}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{ 
        rotateX: springRotateX, 
        rotateY: springRotateY,
        transformStyle: "preserve-3d" 
      }}
      whileTap={{ scale: 0.95 }}
      whileHover={{ scale: 1.05 }}
      className={cn(
        "relative overflow-hidden group style-preserve-3d",
        className
      )}
    >
      {/* Premium Spotlight Effect - Toned Down */}
      <motion.div
        className="pointer-events-none absolute -inset-px opacity-0 transition-opacity duration-300 group-hover:opacity-100 z-0 mix-blend-overlay"
        style={{
          background: useMotionTemplate`
            radial-gradient(
              120px circle at ${mouseX}px ${mouseY}px,
              rgba(255,255,255,0.15),
              transparent 80%
            )
          `,
        }}
      />
      
      {/* Wrapper without exaggerated depth */}
      <span 
        className="relative z-10 flex items-center justify-center gap-3 w-full h-full pointer-events-none"
      >
        {children}
      </span>
    </Component>
  );
}
