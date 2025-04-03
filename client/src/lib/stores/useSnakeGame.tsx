import { create } from "zustand";
import { useAudio } from "./useAudio";

// Define types
type Position = {
  x: number;
  y: number;
};

type Direction = "up" | "down" | "left" | "right";
type GameState = "ready" | "playing" | "paused" | "game-over";

interface SnakeGameState {
  // Canvas properties
  canvasWidth: number;
  canvasHeight: number;
  gridSize: number;
  ctx: CanvasRenderingContext2D | null;
  
  // Game state
  gameState: GameState;
  score: number;
  highScore: number;
  speed: number;
  
  // Snake properties
  snake: Position[];
  direction: Direction;
  nextDirection: Direction;
  
  // Food
  food: Position | null;
  
  // Actions
  setCanvasContext: (ctx: CanvasRenderingContext2D) => void;
  startGame: () => void;
  pauseGame: () => void;
  resetGame: () => void;
  changeDirection: (direction: Direction) => void;
  
  // Internal
  _gameLoopInterval: number | null;
}

export const useSnakeGame = create<SnakeGameState>((set, get) => {
  // Initialize the game state
  const initialState = {
    // Canvas properties
    canvasWidth: 600,
    canvasHeight: 400,
    gridSize: 20,
    ctx: null as CanvasRenderingContext2D | null,
    
    // Game state
    gameState: "ready" as GameState,
    score: 0,
    highScore: 0,
    speed: 150, // ms between moves (lower = faster)
    
    // Snake properties
    snake: [{ x: 10, y: 10 }], // Start with just the head
    direction: "right" as Direction,
    nextDirection: "right" as Direction,
    
    // Food
    food: null as Position | null,
    
    // Internal
    _gameLoopInterval: null as number | null,
  };
  
  // Generate a random position for food
  const generateFood = (): Position => {
    const { canvasWidth, canvasHeight, gridSize, snake } = get();
    
    const maxX = Math.floor(canvasWidth / gridSize) - 1;
    const maxY = Math.floor(canvasHeight / gridSize) - 1;
    
    let newFood: Position;
    let foodOnSnake = true;
    
    // Keep generating positions until we find one that's not on the snake
    while (foodOnSnake) {
      newFood = {
        x: Math.floor(Math.random() * maxX),
        y: Math.floor(Math.random() * maxY),
      };
      
      foodOnSnake = snake.some(
        segment => segment.x === newFood.x && segment.y === newFood.y
      );
    }
    
    return newFood!;
  };
  
  // Move the snake
  const moveSnake = () => {
    const { snake, direction, food, score, highScore, canvasWidth, canvasHeight, gridSize } = get();
    
    // Get the head position
    const head = { ...snake[0] };
    
    // Update the direction based on nextDirection
    set(state => ({ direction: state.nextDirection }));
    
    // Move the head based on the direction
    switch (get().direction) {
      case "up":
        head.y -= 1;
        break;
      case "down":
        head.y += 1;
        break;
      case "left":
        head.x -= 1;
        break;
      case "right":
        head.x += 1;
        break;
    }
    
    // Check if the game is over (collision with wall or self)
    const maxX = Math.floor(canvasWidth / gridSize) - 1;
    const maxY = Math.floor(canvasHeight / gridSize) - 1;
    
    // Wall collision
    if (head.x < 0 || head.x > maxX || head.y < 0 || head.y > maxY) {
      gameOver();
      return;
    }
    
    // Self collision (check if head hits any part of the body)
    for (let i = 1; i < snake.length; i++) {
      if (head.x === snake[i].x && head.y === snake[i].y) {
        gameOver();
        return;
      }
    }
    
    // Create the new snake by adding the new head
    const newSnake = [head, ...snake];
    
    // Check if the snake ate the food
    let newFood = food;
    let newScore = score;
    
    if (food && head.x === food.x && head.y === food.y) {
      // Increase score
      newScore = score + 10;
      
      // Update high score if needed
      const newHighScore = Math.max(newScore, highScore);
      
      // Generate new food
      newFood = generateFood();
      
      // Play success sound
      const { playSuccess } = useAudio.getState();
      playSuccess();
      
      // Don't remove the tail (snake grows)
    } else {
      // Remove the tail
      newSnake.pop();
    }
    
    // Update the state
    set({
      snake: newSnake,
      food: newFood,
      score: newScore,
      highScore: Math.max(newScore, highScore),
    });
  };
  
  // Game over
  const gameOver = () => {
    const { _gameLoopInterval } = get();
    
    // Stop the game loop
    if (_gameLoopInterval) {
      clearInterval(_gameLoopInterval);
    }
    
    // Play hit sound
    const { playHit } = useAudio.getState();
    playHit();
    
    // Update the state
    set({
      gameState: "game-over",
      _gameLoopInterval: null,
    });
  };
  
  // Start the game loop
  const startGameLoop = () => {
    const { speed, _gameLoopInterval } = get();
    
    // Stop any existing game loop
    if (_gameLoopInterval) {
      clearInterval(_gameLoopInterval);
    }
    
    // Start the background music
    const { backgroundMusic, isMuted } = useAudio.getState();
    if (backgroundMusic && !isMuted) {
      backgroundMusic.play().catch(error => {
        console.log("Background music play prevented:", error);
      });
    }
    
    // Start a new game loop
    const interval = setInterval(() => {
      // Only move the snake if the game is playing
      if (get().gameState === "playing") {
        moveSnake();
      }
    }, speed);
    
    // Update the state
    set({ _gameLoopInterval: interval as unknown as number });
  };
  
  // Handle keyboard events
  const handleKeyDown = (e: KeyboardEvent) => {
    const { gameState, direction } = get();
    
    // Only handle keyboard events if the game is playing or ready
    if (gameState !== "playing" && gameState !== "ready") return;
    
    // Start the game if it's ready
    if (gameState === "ready") {
      set({
        gameState: "playing",
        food: generateFood(),
      });
      startGameLoop();
    }
    
    // Handle arrow keys
    switch (e.key) {
      case "ArrowUp":
        // Prevent moving down if already going up
        if (direction !== "down") {
          set({ nextDirection: "up" });
        }
        break;
      case "ArrowDown":
        // Prevent moving up if already going down
        if (direction !== "up") {
          set({ nextDirection: "down" });
        }
        break;
      case "ArrowLeft":
        // Prevent moving right if already going left
        if (direction !== "right") {
          set({ nextDirection: "left" });
        }
        break;
      case "ArrowRight":
        // Prevent moving left if already going right
        if (direction !== "left") {
          set({ nextDirection: "right" });
        }
        break;
      case " ": // Spacebar
        // Pause/resume the game
        if (gameState === "playing") {
          set({ gameState: "paused" });
        } else if (gameState === "paused") {
          set({ gameState: "playing" });
        }
        break;
    }
  };
  
  // Add event listener for keyboard events
  if (typeof window !== "undefined") {
    window.addEventListener("keydown", handleKeyDown);
  }
  
  return {
    ...initialState,
    
    setCanvasContext: (ctx) => set({ ctx }),
    
    startGame: () => {
      const { gameState, _gameLoopInterval } = get();
      
      if (gameState === "ready") {
        // Starting a new game
        set({
          gameState: "playing",
          food: generateFood(),
          score: 0,
          snake: [{ x: 10, y: 10 }],
          direction: "right",
          nextDirection: "right",
        });
        startGameLoop();
      } else if (gameState === "paused") {
        // Resuming an existing game
        set({ gameState: "playing" });
        
        // If the game loop isn't running, start it
        if (!_gameLoopInterval) {
          startGameLoop();
        }
      }
    },
    
    pauseGame: () => {
      const { gameState } = get();
      
      if (gameState === "playing") {
        set({ gameState: "paused" });
      }
    },
    
    resetGame: () => {
      const { _gameLoopInterval } = get();
      
      // Stop the game loop
      if (_gameLoopInterval) {
        clearInterval(_gameLoopInterval);
      }
      
      // Reset the game state
      set({
        gameState: "ready",
        score: 0,
        snake: [{ x: 10, y: 10 }],
        direction: "right",
        nextDirection: "right",
        food: null,
        _gameLoopInterval: null,
      });
    },
    
    changeDirection: (newDirection) => {
      const { direction } = get();
      
      // Prevent 180-degree turns
      const invalidTurns = {
        up: "down",
        down: "up",
        left: "right",
        right: "left",
      };
      
      if (invalidTurns[newDirection] !== direction) {
        set({ nextDirection: newDirection });
      }
    },
  };
});
