import { Button } from "@/components/ui/button";
import { useSnakeGame } from "@/lib/stores/useSnakeGame";
import { useAudio } from "@/lib/stores/useAudio";
import { Play, Pause, Volume2, VolumeX, RefreshCw } from "lucide-react";

const Controls = () => {
  const { gameState, startGame, pauseGame, resetGame } = useSnakeGame();
  const { isMuted, toggleMute } = useAudio();

  return (
    <div className="flex gap-2 mt-4">
      {gameState === "ready" && (
        <Button 
          onClick={startGame} 
          className="bg-green-600 hover:bg-green-700 text-white"
        >
          <Play className="mr-2 h-4 w-4" />
          Start Game
        </Button>
      )}
      
      {gameState === "playing" && (
        <Button 
          onClick={pauseGame} 
          className="bg-yellow-600 hover:bg-yellow-700 text-white"
        >
          <Pause className="mr-2 h-4 w-4" />
          Pause
        </Button>
      )}
      
      {gameState === "paused" && (
        <Button 
          onClick={startGame} 
          className="bg-green-600 hover:bg-green-700 text-white"
        >
          <Play className="mr-2 h-4 w-4" />
          Resume
        </Button>
      )}
      
      {(gameState === "paused" || gameState === "playing") && (
        <Button 
          onClick={resetGame} 
          className="bg-red-600 hover:bg-red-700 text-white"
        >
          <RefreshCw className="mr-2 h-4 w-4" />
          Restart
        </Button>
      )}
      
      <Button 
        onClick={toggleMute} 
        variant="outline" 
        className="border-gray-600 text-gray-300"
      >
        {isMuted ? (
          <VolumeX className="h-4 w-4" />
        ) : (
          <Volume2 className="h-4 w-4" />
        )}
      </Button>
    </div>
  );
};

export default Controls;
