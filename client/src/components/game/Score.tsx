import { useSnakeGame } from "@/lib/stores/useSnakeGame";

const Score = () => {
  const { score, highScore } = useSnakeGame();

  return (
    <div className="flex justify-between w-full max-w-md my-4">
      <div className="bg-gray-800 rounded-lg p-3 text-center shadow-md w-[48%]">
        <h3 className="text-green-400 text-sm font-medium mb-1">Score</h3>
        <p className="text-white text-2xl font-bold">{score}</p>
      </div>
      
      <div className="bg-gray-800 rounded-lg p-3 text-center shadow-md w-[48%]">
        <h3 className="text-yellow-400 text-sm font-medium mb-1">High Score</h3>
        <p className="text-white text-2xl font-bold">{highScore}</p>
      </div>
    </div>
  );
};

export default Score;
