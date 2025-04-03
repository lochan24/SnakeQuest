import { Button } from "@/components/ui/button";
import { useSnakeGame } from "@/lib/stores/useSnakeGame";

const GameOver = () => {
  const { score, resetGame } = useSnakeGame();

  return (
    <div className="absolute inset-0 bg-black bg-opacity-80 flex flex-col items-center justify-center rounded-lg">
      <h2 className="text-red-500 text-4xl font-bold mb-4">Game Over!</h2>
      <p className="text-white text-xl mb-6">Final Score: {score}</p>
      
      <Button 
        onClick={resetGame}
        variant="default"
        className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-semibold text-lg"
      >
        Play Again
      </Button>
    </div>
  );
};

export default GameOver;
