type Position = {
  x: number;
  y: number;
};

const Food = (
  ctx: CanvasRenderingContext2D, 
  food: Position, 
  gridSize: number
) => {
  // Create an apple shape
  const centerX = food.x * gridSize + gridSize / 2;
  const centerY = food.y * gridSize + gridSize / 2;
  const radius = gridSize / 2 - 2;
  
  // Draw the main apple body
  const gradient = ctx.createRadialGradient(
    centerX - radius / 3, 
    centerY - radius / 3, 
    radius / 8,
    centerX, 
    centerY, 
    radius
  );
  gradient.addColorStop(0, "#EF4444"); // Red-500
  gradient.addColorStop(1, "#B91C1C"); // Red-700
  
  ctx.fillStyle = gradient;
  ctx.beginPath();
  ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
  ctx.fill();
  
  // Draw the stem
  ctx.fillStyle = "#78350F"; // Brown
  ctx.beginPath();
  ctx.roundRect(
    centerX - 2,
    food.y * gridSize + 2,
    4,
    5,
    1
  );
  ctx.fill();
  
  // Draw a leaf
  ctx.fillStyle = "#15803D"; // Green-700
  ctx.beginPath();
  ctx.ellipse(
    centerX + 4,
    food.y * gridSize + 5,
    5,
    3,
    Math.PI / 4,
    0,
    Math.PI * 2
  );
  ctx.fill();
  
  // Add a shine effect
  ctx.fillStyle = "rgba(255, 255, 255, 0.3)";
  ctx.beginPath();
  ctx.arc(
    centerX - radius / 3,
    centerY - radius / 3,
    radius / 4,
    0,
    Math.PI * 2
  );
  ctx.fill();
};

export default Food;
