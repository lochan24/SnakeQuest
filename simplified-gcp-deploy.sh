#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting ultra-simplified GCP deployment preparation..."

# Clean up any previous build
echo "🧹 Cleaning up old builds..."
rm -rf gcp-simplified

# Create deployment directory
echo "📁 Creating deployment directory..."
mkdir -p gcp-simplified

# Create a static version of the snake game
echo "📋 Creating static game..."

# Create package.json for the static deployment
cat > gcp-simplified/package.json << 'EOL'
{
  "name": "snake-game-static",
  "version": "1.0.0",
  "type": "module",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOL

# Create a basic server
cat > gcp-simplified/server.js << 'EOL'
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// For all other routes, serve the index.html file
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Snake Game server running on port ${PORT}`);
});
EOL

# Create app.yaml
cat > gcp-simplified/app.yaml << 'EOL'
runtime: nodejs20
instance_class: F1
automatic_scaling:
  min_idle_instances: 0
  max_idle_instances: 1
  min_instances: 0
  max_instances: 1
EOL

# Create public directory
mkdir -p gcp-simplified/public

# Create a static HTML snake game (no build needed)
cat > gcp-simplified/public/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Snake Game</title>
  <style>
    body {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background-color: #2c3e50;
      font-family: Arial, sans-serif;
    }
    
    .game-container {
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    
    canvas {
      border: 2px solid #ecf0f1;
      background-color: #34495e;
    }
    
    .score-container {
      display: flex;
      justify-content: space-between;
      width: 400px;
      color: #ecf0f1;
      margin-bottom: 10px;
    }
    
    .controls {
      margin-top: 20px;
      color: #ecf0f1;
      text-align: center;
    }
    
    .game-over {
      position: absolute;
      background-color: rgba(0, 0, 0, 0.8);
      color: white;
      padding: 20px;
      border-radius: 10px;
      text-align: center;
      display: none;
    }
    
    button {
      background-color: #3498db;
      border: none;
      color: white;
      padding: 10px 20px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      font-size: 16px;
      margin: 10px 2px;
      cursor: pointer;
      border-radius: 5px;
    }
    
    button:hover {
      background-color: #2980b9;
    }

    .mute-button {
      position: absolute;
      top: 10px;
      right: 10px;
      background-color: #7f8c8d;
      padding: 5px 10px;
      border-radius: 5px;
    }
  </style>
</head>
<body>
  <div class="game-container">
    <div class="score-container">
      <div>Score: <span id="score">0</span></div>
      <div>High Score: <span id="high-score">0</span></div>
    </div>
    
    <canvas id="game-canvas" width="400" height="400"></canvas>
    
    <div class="controls">
      <p>Use Arrow Keys or WASD to move the snake</p>
      <button id="start-button">Start Game</button>
      <button id="pause-button">Pause</button>
    </div>
    
    <div id="game-over" class="game-over">
      <h2>Game Over!</h2>
      <p>Your score: <span id="final-score">0</span></p>
      <button id="restart-button">Play Again</button>
    </div>
  </div>
  
  <button id="mute-button" class="mute-button">🔊</button>
  
  <script>
    // Game Constants
    const GRID_SIZE = 20;
    const GAME_SPEED = 150;
    
    // Game Variables
    let canvas = document.getElementById('game-canvas');
    let ctx = canvas.getContext('2d');
    let snake = [{x: 10, y: 10}];
    let food = null;
    let direction = 'right';
    let nextDirection = 'right';
    let gameInterval = null;
    let score = 0;
    let highScore = localStorage.getItem('snakeHighScore') || 0;
    let gameState = 'ready'; // ready, playing, paused, game-over
    
    // Audio
    let eatSound = new Audio('data:audio/wav;base64,UklGRiQJAABXQVZFZm10IBAAAAABAAIARKwAAESsAAABAAgAZGF0YQAJAACAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIB3d4iIiJmZmYyMjHd3d2ZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZmYyMjHd3d2ZmZmZmZmZ3d3eIiIiZmZmZmZmZmZmZmYyMjHd3d2ZmZmZmZmZ3d3d3eHiIiIiZmZmMjIx3d3dmZmZmZmZ3d3eIiIiZmZmZmZmZmZmZmZmMjIx3d3dmZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmMjIx3d3dmZmZmZmZmd3d3d3h4iIiImZmZjIyMd3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d4iIiIyMjIyMjHd3d2ZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZmYyMjHd3d2ZmZmZmZmZ3d3eIiIiZmZmZmZmZmZmZmYyMjHd3d2ZmZmZmZmZ3d3d3d3eIiIiMjIyMjIx3d3dmZmZmZmZ3d3eIiIiZmZmZmZmZmZmZmZmMjIx3d3dmZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmMjIx3d3dmZmZmZmZmd3d3d3d3iIiIjIyMjIyMd3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eIiIyMjIx3d3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4yMjIx3d3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eIiIh3d3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eIiIh3d3d3ZmZmZmZmd3d3iIiImZmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eIiIh3d3d3ZmZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eIiIh3d3d3ZmZmZmZmdnd3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eHiIh3d3d3Z2ZmZmZmdnd3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eHiIh3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3d3eHh4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d4eHh4d3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d3h4eHh3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d3h4eHh3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnd3d3d3dnd3d3h4eHh3d3d3Z2ZmZmZmd3d3eIiIiJmZmZmZmZmZmZmMjIyMd3d3ZmZmZmZmZnd3d4iIiJmZmZmZmZmZmZmZjIyMd3d3ZmZmZmZmZnZ2dnZ2dnZ2dnd3d3d2dnZ2ZmZmZmZmZmZmZmZmdnd3d3d3d3Z2dnZ2dm9vb29vb29vb29vb29vb29vb29vb29vb20==');
    let gameOverSound = new Audio('data:audio/wav;base64,UklGRnQJAABXQVZFZm10IBAAAAABAAIARKwAAESsAAABAAgAZGF0YVAJAACAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBgYKCgoKCgoGBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/fn5+fn9/gICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/fn5+fn9/gICBgYKCgoODg4ODgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/fn5+fn9/gICBgYGCgoODg4ODgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9+fn5+fn+AgICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/fn5+fn9/gICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH5+fn5+fn+AgICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH5+fn5+fn+AgICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH5+fn5+fn+AgICBgYKCgoODg4OCgoKBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAgH9/f39/f4CAgIGBgoKCg4ODg4ODgoKCgYGAfn5+fn5+f3+AgIGBgoKCg4ODg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4ODgoKCgYGAgH5+fn5+fn9/gICBgYKCgoODg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4ODgoKCgYGAgH5+fn5+fn9/gICBgYKCgoKDg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4ODgoKCgYGAgH5+fn5+fn9/gICBgYKCgoKDg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4ODgoKCgYGAgH5+fn5+fn9/gICBgYKCgoKDg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4ODgoKCgYGAgH5+fn5+fn9/gICBgYKCgoKDg4KCgoGBgICAgH9/f39/gICAgYGCgoKDg4ODg4KCgoGBgICAf39/f3+AgICBgYKCgoODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKDgoODgoKCgYGBgICAf39/f39/gICAgYGCgoKDg4ODg4SDg4KCgYGAgIB/gIB/gICAgIGBgYKCgoOCg4OCgoKBgYGAgIB/f39/f3+AgICBgYKCgoODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKCg4ODgoKCgYGBgICAf39/f39/gICAgYGCgoKDg4ODg4SDg4KCgYGAgIB/gIB/gICAgIGBgYKCgoKDg4OCgoKBgYGAgIB/f39/f3+AgICBgYKCgoODg4ODhIODgoKBgYCAgH+AgH+AgICAgYGBgoKCgoODg4KCgoGBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKCg4ODgoKCgYGBgICAf39/f39/gICAgYGCgoKDg4ODg4SDg4KCgYGAgIB/gIB/gICAgIGBgYKCgoKDg4OCgoKBgYGAgIB/f39/f3+AgICBgYKCgoODg4ODhIODgoKBgYCAgH+AgH+AgICAgYGBgoKCgoODg4KCgoGBgYCAgH9/f39/f4CAgIGBgoKCg4ODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKCg4ODgoKCgYGBgICAf39/f39/gICAgYGCgoKDg4ODg4SDg4KCgYGAgIB/gIB/gICAgIGBgYKCgoODg4OCgoKBgYGAgIB/f39/f3+AgICBgYKCgoODg4ODhIODgoKBgYCAgH+AgH+AgICAgYGBgoKCg4ODg4KCgoGBgYCAgH9/f39/f4CAgICBgYKCgoODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4OEg4OCgoGBgICAf4CAf4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4SDhIODgoKBgYCAf3+Af4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4SDhIODgoKBgYCAf3+Af4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4SDhIODgoKBgYCAf3+Af4CAgICBgYGCgoKDg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4SDhIODgoKBgYCAf3+Af4CAgICAgYGBgoODg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4SDhIODgoKBgYCAf3+Af4CAgICAgYGBgoODg4ODgoKCgYGBgICAf39/f39/gICAgICBgYKCgoODg4SDhIODgoKBgYCAf3+Af4CAgICAgYGBgoODg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4OEhIODgoKBgYCAf3+Af4CAgICAgYGBgoODg4ODgoKCgYGBgICAf39/f39/gICAgIGBgoKCg4ODg4OEhIODgoKBgYCAf3+A');
    
    let isMuted = false;
    
    // Update High Score Display
    document.getElementById('high-score').textContent = highScore;
    
    // Generate random food position
    function generateFood() {
      let newFood;
      let foodOnSnake;
      
      do {
        foodOnSnake = false;
        newFood = {
          x: Math.floor(Math.random() * (canvas.width / GRID_SIZE)),
          y: Math.floor(Math.random() * (canvas.height / GRID_SIZE))
        };
        
        // Check if food is on snake
        for (let segment of snake) {
          if (segment.x === newFood.x && segment.y === newFood.y) {
            foodOnSnake = true;
            break;
          }
        }
      } while (foodOnSnake);
      
      return newFood;
    }
    
    // Draw everything on canvas
    function draw() {
      // Clear canvas
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      // Draw snake
      ctx.fillStyle = '#2ecc71';
      snake.forEach((segment, index) => {
        // Head is a different color
        if (index === 0) {
          ctx.fillStyle = '#27ae60';
        } else {
          ctx.fillStyle = '#2ecc71';
        }
        
        ctx.fillRect(segment.x * GRID_SIZE, segment.y * GRID_SIZE, GRID_SIZE, GRID_SIZE);
        
        // Add eyes to the head
        if (index === 0) {
          ctx.fillStyle = 'white';
          
          // Position eyes based on direction
          let eyeSize = GRID_SIZE / 5;
          let eyeOffset = GRID_SIZE / 3;
          
          if (direction === 'right') {
            ctx.fillRect((segment.x * GRID_SIZE) + GRID_SIZE - eyeOffset, (segment.y * GRID_SIZE) + eyeOffset, eyeSize, eyeSize);
            ctx.fillRect((segment.x * GRID_SIZE) + GRID_SIZE - eyeOffset, (segment.y * GRID_SIZE) + GRID_SIZE - eyeOffset - eyeSize, eyeSize, eyeSize);
          } else if (direction === 'left') {
            ctx.fillRect((segment.x * GRID_SIZE) + eyeOffset - eyeSize, (segment.y * GRID_SIZE) + eyeOffset, eyeSize, eyeSize);
            ctx.fillRect((segment.x * GRID_SIZE) + eyeOffset - eyeSize, (segment.y * GRID_SIZE) + GRID_SIZE - eyeOffset - eyeSize, eyeSize, eyeSize);
          } else if (direction === 'up') {
            ctx.fillRect((segment.x * GRID_SIZE) + eyeOffset, (segment.y * GRID_SIZE) + eyeOffset - eyeSize, eyeSize, eyeSize);
            ctx.fillRect((segment.x * GRID_SIZE) + GRID_SIZE - eyeOffset - eyeSize, (segment.y * GRID_SIZE) + eyeOffset - eyeSize, eyeSize, eyeSize);
          } else if (direction === 'down') {
            ctx.fillRect((segment.x * GRID_SIZE) + eyeOffset, (segment.y * GRID_SIZE) + GRID_SIZE - eyeOffset, eyeSize, eyeSize);
            ctx.fillRect((segment.x * GRID_SIZE) + GRID_SIZE - eyeOffset - eyeSize, (segment.y * GRID_SIZE) + GRID_SIZE - eyeOffset, eyeSize, eyeSize);
          }
        }
      });
      
      // Draw food
      if (food) {
        ctx.fillStyle = '#e74c3c';
        ctx.beginPath();
        ctx.arc(
          (food.x * GRID_SIZE) + GRID_SIZE / 2,
          (food.y * GRID_SIZE) + GRID_SIZE / 2,
          GRID_SIZE / 2,
          0,
          Math.PI * 2
        );
        ctx.fill();
        
        // Add a leaf
        ctx.fillStyle = '#27ae60';
        ctx.beginPath();
        ctx.arc(
          (food.x * GRID_SIZE) + GRID_SIZE * 0.7,
          (food.y * GRID_SIZE) + GRID_SIZE * 0.3,
          GRID_SIZE / 6,
          0,
          Math.PI * 2
        );
        ctx.fill();
      }
      
      // Draw grid (optional)
      if (false) { // Set to true to see grid
        ctx.strokeStyle = '#3a506b';
        ctx.lineWidth = 0.5;
        
        for (let i = 0; i <= canvas.width; i += GRID_SIZE) {
          ctx.beginPath();
          ctx.moveTo(i, 0);
          ctx.lineTo(i, canvas.height);
          ctx.stroke();
        }
        
        for (let j = 0; j <= canvas.height; j += GRID_SIZE) {
          ctx.beginPath();
          ctx.moveTo(0, j);
          ctx.lineTo(canvas.width, j);
          ctx.stroke();
        }
      }
    }
    
    // Move the snake
    function moveSnake() {
      // Get the head position
      let head = { x: snake[0].x, y: snake[0].y };
      
      // Update direction from nextDirection
      direction = nextDirection;
      
      // Calculate new head position
      switch (direction) {
        case 'up':
          head = { x: head.x, y: head.y - 1 };
          break;
        case 'down':
          head = { x: head.x, y: head.y + 1 };
          break;
        case 'left':
          head = { x: head.x - 1, y: head.y };
          break;
        case 'right':
          head = { x: head.x + 1, y: head.y };
          break;
      }
      
      // Check for collisions with walls
      if (
        head.x < 0 ||
        head.y < 0 ||
        head.x >= canvas.width / GRID_SIZE ||
        head.y >= canvas.height / GRID_SIZE
      ) {
        return gameOver();
      }
      
      // Check for collisions with self
      for (let segment of snake) {
        if (head.x === segment.x && head.y === segment.y) {
          return gameOver();
        }
      }
      
      // Add new head to beginning of snake array
      snake.unshift(head);
      
      // Check if snake ate food
      if (food && head.x === food.x && head.y === food.y) {
        // Increase score
        score += 10;
        document.getElementById('score').textContent = score;
        
        // Play eat sound
        if (!isMuted) {
          eatSound.currentTime = 0;
          eatSound.play();
        }
        
        // Generate new food
        food = generateFood();
      } else {
        // Remove the last segment of the snake if it didn't eat
        snake.pop();
      }
    }
    
    // Game loop
    function gameLoop() {
      if (gameState === 'playing') {
        moveSnake();
        draw();
      }
    }
    
    // Start game function
    function startGame() {
      if (gameState === 'ready' || gameState === 'game-over') {
        // Reset snake
        snake = [{ x: 10, y: 10 }];
        
        // Reset direction
        direction = 'right';
        nextDirection = 'right';
        
        // Generate food
        food = generateFood();
        
        // Reset score
        score = 0;
        document.getElementById('score').textContent = score;
        
        // Hide game over screen
        document.getElementById('game-over').style.display = 'none';
        
        // Set game state to playing
        gameState = 'playing';
        
        // Start game interval
        clearInterval(gameInterval);
        gameInterval = setInterval(gameLoop, GAME_SPEED);
        
        // Focus canvas for keyboard controls
        canvas.focus();
      } else if (gameState === 'paused') {
        // Resume game from pause
        gameState = 'playing';
        gameInterval = setInterval(gameLoop, GAME_SPEED);
      }
    }
    
    // Pause game function
    function pauseGame() {
      if (gameState === 'playing') {
        gameState = 'paused';
        clearInterval(gameInterval);
      }
    }
    
    // Game over function
    function gameOver() {
      gameState = 'game-over';
      clearInterval(gameInterval);
      
      // Update high score if needed
      if (score > highScore) {
        highScore = score;
        localStorage.setItem('snakeHighScore', highScore);
        document.getElementById('high-score').textContent = highScore;
      }
      
      // Show game over screen
      document.getElementById('final-score').textContent = score;
      document.getElementById('game-over').style.display = 'block';
      
      // Play game over sound
      if (!isMuted) {
        gameOverSound.currentTime = 0;
        gameOverSound.play();
      }
    }
    
    // Handle keyboard input
    document.addEventListener('keydown', (e) => {
      // Prevent default actions for arrow keys
      if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'w', 'a', 's', 'd'].includes(e.key)) {
        e.preventDefault();
      }
      
      // Don't change direction if game is not playing
      if (gameState !== 'playing') return;
      
      // Update direction based on key pressed
      switch (e.key) {
        case 'ArrowUp':
        case 'w':
        case 'W':
          if (direction !== 'down') {
            nextDirection = 'up';
          }
          break;
        case 'ArrowDown':
        case 's':
        case 'S':
          if (direction !== 'up') {
            nextDirection = 'down';
          }
          break;
        case 'ArrowLeft':
        case 'a':
        case 'A':
          if (direction !== 'right') {
            nextDirection = 'left';
          }
          break;
        case 'ArrowRight':
        case 'd':
        case 'D':
          if (direction !== 'left') {
            nextDirection = 'right';
          }
          break;
        case ' ':
          // Space to pause/resume
          if (gameState === 'playing') {
            pauseGame();
          } else if (gameState === 'paused') {
            startGame();
          }
          break;
      }
    });
    
    // Button event listeners
    document.getElementById('start-button').addEventListener('click', startGame);
    document.getElementById('pause-button').addEventListener('click', pauseGame);
    document.getElementById('restart-button').addEventListener('click', startGame);
    
    // Mute button
    document.getElementById('mute-button').addEventListener('click', function() {
      isMuted = !isMuted;
      this.textContent = isMuted ? '🔇' : '🔊';
    });
    
    // Draw initial screen
    draw();
  </script>
</body>
</html>
EOL

# Create a simple README
cat > gcp-simplified/README.md << 'EOL'
# Snake Game GCP Deployment

## Simple Deployment Instructions

1. Upload this entire directory to GCP Cloud Shell
2. Run: `gcloud app deploy app.yaml`
3. Open the deployed app with: `gcloud app browse`

This is a simplified deployment package that doesn't require a build step.
The game is entirely self-contained in a single HTML file with inline JavaScript.
EOL

echo "✅ Simplified GCP deployment preparation complete!"
echo "To deploy to Google Cloud App Engine:"
echo "1. Upload the gcp-simplified directory to Google Cloud Shell"
echo "2. Run: gcloud app deploy app.yaml from within the gcp-simplified directory"