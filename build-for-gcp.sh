#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting GCP deployment preparation..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the client application directly without Vite configuration changes
echo "🔨 Building client application..."
npm run build

# Create a deployment directory
echo "📁 Creating deployment directory..."
rm -rf deploy
mkdir -p deploy/client/dist

# Check where the build output is located
if [ -d "dist/public" ]; then
  # Output is in dist/public as per vite config
  echo "📋 Copying from dist/public..."
  cp -r dist/public/* deploy/client/dist/
elif [ -d "dist/assets" ]; then
  # Output is directly in dist
  echo "📋 Copying from dist..."
  cp -r dist/* deploy/client/dist/
else
  echo "❌ Could not find build output. Please check the build configuration."
  exit 1
fi

# Copy the server files
echo "📋 Setting up server files..."
cp server.js deploy/
cp dist-package.json deploy/package.json
cp app-engine.yaml deploy/app.yaml

echo "✅ Deployment preparation complete!"
echo "To deploy to Google Cloud App Engine, navigate to the deploy directory and run:"
echo "gcloud app deploy app.yaml"