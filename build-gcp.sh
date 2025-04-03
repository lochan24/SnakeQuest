#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting simplified GCP deployment preparation..."

# Clean up any previous build
echo "🧹 Cleaning up old builds..."
rm -rf gcp-deploy

# Create a deployment directory
echo "📁 Creating deployment directory..."
mkdir -p gcp-deploy

# Copy the client's source files directly (no build required)
echo "📋 Copying client source..."
mkdir -p gcp-deploy/client/src
cp -r client/src gcp-deploy/client/
cp client/index.html gcp-deploy/client/
mkdir -p gcp-deploy/client/public
cp -r client/public/* gcp-deploy/client/public/

# Copy static server.js for GCP
echo "📋 Setting up static server..."
cat > gcp-deploy/server.js << 'EOL'
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;

// Serve static files from the dist directory
app.use(express.static(path.join(__dirname, 'dist')));

// For all other routes, serve the index.html file
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOL

# Create deployment package.json with only what's needed
echo "📋 Creating package.json..."
cat > gcp-deploy/package.json << 'EOL'
{
  "name": "snake-game",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "vite build",
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8"
  }
}
EOL

# Create a simplified app.yaml for GCP
echo "📋 Creating app.yaml..."
cat > gcp-deploy/app.yaml << 'EOL'
runtime: nodejs20

instance_class: F1

handlers:
  - url: /.*
    secure: always
    script: auto
EOL

# Create a simple README with instructions
echo "📋 Creating README..."
cat > gcp-deploy/README.md << 'EOL'
# Snake Game Deployment

1. Navigate to this directory on GCP Cloud Shell
2. Run: `npm install`
3. Run: `npm run build`
4. Run: `gcloud app deploy app.yaml`
5. Open the deployed app with: `gcloud app browse`
EOL

echo "✅ GCP deployment preparation complete!"
echo "To deploy to Google Cloud App Engine:"
echo "1. Upload the gcp-deploy directory to Google Cloud Shell"
echo "2. Follow the instructions in the README.md file"