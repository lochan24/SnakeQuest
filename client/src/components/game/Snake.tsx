type Position = {
  x: number;
  y: number;
};

const Snake = (
  ctx: CanvasRenderingContext2D, 
  snake: Position[], 
  gridSize: number
) => {
  if (!snake.length) return;

  // Draw the snake body segments
  for (let i = 1; i < snake.length; i++) {
    const segment = snake[i];
    
    // Gradient for snake body
    const gradient = ctx.createLinearGradient(
      segment.x * gridSize, 
      segment.y * gridSize,
      (segment.x + 1) * gridSize, 
      (segment.y + 1) * gridSize
    );
    gradient.addColorStop(0, "#10B981"); // Green-500
    gradient.addColorStop(1, "#059669"); // Green-600
    
    ctx.fillStyle = gradient;
    
    // Draw rounded rectangle for each segment
    ctx.beginPath();
    ctx.roundRect(
      segment.x * gridSize + 1, 
      segment.y * gridSize + 1, 
      gridSize - 2, 
      gridSize - 2,
      4 // rounded corners
    );
    ctx.fill();
  }

  // Draw the snake head
  const head = snake[0];
  
  // Gradient for snake head
  const headGradient = ctx.createLinearGradient(
    head.x * gridSize, 
    head.y * gridSize,
    (head.x + 1) * gridSize, 
    (head.y + 1) * gridSize
  );
  headGradient.addColorStop(0, "#047857"); // Green-700
  headGradient.addColorStop(1, "#065F46"); // Green-800
  
  ctx.fillStyle = headGradient;
  
  // Draw rounded rectangle for head
  ctx.beginPath();
  ctx.roundRect(
    head.x * gridSize + 1, 
    head.y * gridSize + 1, 
    gridSize - 2, 
    gridSize - 2,
    8 // more rounded corners for the head
  );
  ctx.fill();
  
  // Draw eyes
  ctx.fillStyle = "white";
  
  // Left eye
  ctx.beginPath();
  ctx.arc(
    head.x * gridSize + gridSize * 0.3,
    head.y * gridSize + gridSize * 0.3,
    gridSize * 0.15,
    0,
    Math.PI * 2
  );
  ctx.fill();
  
  // Right eye
  ctx.beginPath();
  ctx.arc(
    head.x * gridSize + gridSize * 0.7,
    head.y * gridSize + gridSize * 0.3,
    gridSize * 0.15,
    0,
    Math.PI * 2
  );
  ctx.fill();
  
  // Draw pupils
  ctx.fillStyle = "black";
  
  // Left pupil
  ctx.beginPath();
  ctx.arc(
    head.x * gridSize + gridSize * 0.3,
    head.y * gridSize + gridSize * 0.3,
    gridSize * 0.07,
    0,
    Math.PI * 2
  );
  ctx.fill();
  
  // Right pupil
  ctx.beginPath();
  ctx.arc(
    head.x * gridSize + gridSize * 0.7,
    head.y * gridSize + gridSize * 0.3,
    gridSize * 0.07,
    0,
    Math.PI * 2
  );
  ctx.fill();
};

export default Snake;
