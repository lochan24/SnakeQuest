#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting deployment process..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the client-side application
echo "🔨 Building client application..."
cd client
npm install
npm run build
cd ..

# Create a deployment directory
echo "📁 Creating deployment directory..."
rm -rf deploy
mkdir -p deploy/client/dist

# Copy the built client files
echo "📋 Copying client files..."
cp -r client/dist/* deploy/client/dist/

# Copy the server files
echo "📋 Setting up server files..."
cp server.js deploy/
cp dist-package.json deploy/package.json
cp app-engine.yaml deploy/app.yaml

echo "✅ Deployment preparation complete!"
echo "To deploy to Google Cloud App Engine, navigate to the deploy directory and run:"
echo "gcloud app deploy app.yaml"