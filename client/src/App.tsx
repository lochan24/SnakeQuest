import { useEffect } from "react";
import Canvas from "./components/game/Canvas";
import Score from "./components/game/Score";
import GameOver from "./components/game/GameOver";
import Controls from "./components/game/Controls";
import { useSnakeGame } from "./lib/stores/useSnakeGame";
import { useAudio } from "./lib/stores/useAudio";
import "@fontsource/inter";

function App() {
  const { gameState } = useSnakeGame();
  const { setBackgroundMusic, setHitSound, setSuccessSound, toggleMute } = useAudio();

  // Load audio assets
  useEffect(() => {
    // Set up background music
    const bgMusic = new Audio("/sounds/background.mp3");
    bgMusic.loop = true;
    bgMusic.volume = 0.3;
    setBackgroundMusic(bgMusic);

    // Set up hit sound (for game over)
    const hitSfx = new Audio("/sounds/hit.mp3");
    setHitSound(hitSfx);

    // Set up success sound (for eating food)
    const successSfx = new Audio("/sounds/success.mp3");
    setSuccessSound(successSfx);

    // Start with unmuted sound
    toggleMute();

    return () => {
      // Clean up audio
      bgMusic.pause();
      hitSfx.pause();
      successSfx.pause();
    };
  }, [setBackgroundMusic, setHitSound, setSuccessSound, toggleMute]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900 p-4">
      <h1 className="text-4xl font-bold text-green-500 mb-4">Snake Game</h1>
      
      <div className="relative">
        <Canvas />
        {gameState === "game-over" && <GameOver />}
      </div>
      
      <Score />
      <Controls />

      <div className="text-gray-400 text-sm mt-8">
        Use arrow keys to control the snake
      </div>
    </div>
  );
}

export default App;
