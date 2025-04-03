# Snake Game

A classic Snake game built with React and HTML Canvas.

## Features

- Canvas-based rendering with grid background
- Snake movement with arrow key controls
- Food spawning and collision detection
- Score tracking and high score persistence
- Game state management (ready, playing, paused, game-over)
- Sound effects for eating food and game over

## Development

To start the development server:

```bash
npm run dev
```

## Deployment on Cloud Platforms

### Prerequisites

- Make the deployment script executable:
  ```bash
  chmod +x ./deploy.sh
  ```

### Google Cloud Platform (App Engine)

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Authenticate with GCP:
   ```bash
   gcloud auth login
   ```
3. Set your project:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```
4. Run the deployment script to prepare your application:
   ```bash
   ./deploy.sh
   ```
5. Navigate to the dist directory:
   ```bash
   cd dist
   ```
6. Deploy to App Engine:
   ```bash
   gcloud app deploy app.yaml
   ```

### Generic Cloud Deployment

For other cloud platforms:

1. Run the deployment script to build the application:
   ```bash
   ./deploy.sh
   ```
2. The `dist` directory will contain your built application
3. Deploy the contents of the `dist` directory to your preferred cloud platform

## Controls

- Arrow keys: Change snake direction
- Spacebar: Pause/Resume game
- Start button: Begin game
- Restart button: Start a new game