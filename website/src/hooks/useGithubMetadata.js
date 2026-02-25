import { useState, useEffect } from 'react';

export function useGithubMetadata() {
  const [stars, setStars] = useState(null);
  
  useEffect(() => {
    fetch('https://api.github.com/repos/Prakhar0206/WinOptimizer')
      .then(res => res.json())
      .then(data => {
        if(data.stargazers_count !== undefined) {
          setStars(data.stargazers_count);
        }
      })
      .catch(err => console.error("Failed to fetch Github stars:", err));
  }, []);

  return { stars };
}
