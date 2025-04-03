import { useEffect, useRef } from "react";
import { useSnakeGame } from "@/lib/stores/useSnakeGame";
import Snake from "./Snake";
import Food from "./Food";

const Canvas = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const { 
    gameState, 
    snake, 
    food, 
    gridSize, 
    canvasWidth, 
    canvasHeight, 
    setCanvasContext 
  } = useSnakeGame();

  // Initialize the canvas and game loop
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    // Store the canvas context in the game state
    setCanvasContext(ctx);

    // Set the actual canvas size
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;

    // Draw the grid background
    const drawGrid = () => {
      ctx.fillStyle = "#111827"; // Dark background
      ctx.fillRect(0, 0, canvasWidth, canvasHeight);

      // Optional: Draw grid lines
      ctx.strokeStyle = "#1F2937";
      ctx.lineWidth = 1;

      // Draw vertical lines
      for (let x = 0; x <= canvasWidth; x += gridSize) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, canvasHeight);
        ctx.stroke();
      }

      // Draw horizontal lines
      for (let y = 0; y <= canvasHeight; y += gridSize) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(canvasWidth, y);
        ctx.stroke();
      }
    };

    // Game render function
    const render = () => {
      // Clear the canvas
      ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      
      // Draw the grid
      drawGrid();
      
      // Only render game elements if the game is active
      if (gameState === "playing" || gameState === "game-over") {
        // Draw food
        if (food) {
          Food(ctx, food, gridSize);
        }
        
        // Draw snake
        if (snake.length > 0) {
          Snake(ctx, snake, gridSize);
        }
      }
    };

    // Initial render
    render();

    // Set up a render loop
    const renderLoop = setInterval(render, 1000 / 60); // 60fps

    return () => {
      clearInterval(renderLoop);
    };
  }, [canvasWidth, canvasHeight, food, gameState, gridSize, setCanvasContext, snake]);

  return (
    <canvas
      ref={canvasRef}
      className="border-4 border-green-500 rounded-lg shadow-lg"
      width={canvasWidth}
      height={canvasHeight}
    />
  );
};

export default Canvas;
