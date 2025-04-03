# Google Cloud Platform Deployment Guide

This guide provides step-by-step instructions for deploying the Snake Game to Google Cloud Platform's App Engine.

## Prerequisites

1. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
2. Google Cloud account with billing enabled
3. App Engine enabled for your GCP project

## Deployment Steps

### 1. Initial Setup

If you haven't already set up your GCP project:

```bash
# Login to your Google Cloud account
gcloud auth login

# Create a new project (if needed)
gcloud projects create [YOUR_PROJECT_ID] --name="Snake Game"

# Set the current project
gcloud config set project [YOUR_PROJECT_ID]

# Enable App Engine (select a region when prompted)
gcloud app create
```

### 2. Prepare Your Application

```bash
# Make the deployment script executable
chmod +x ./deploy.sh

# Run the deployment script
./deploy.sh
```

### 3. Deploy to App Engine

```bash
# Navigate to the deploy directory
cd deploy

# Deploy to App Engine
gcloud app deploy app.yaml
```

### 4. View Your Deployed Application

```bash
# Open the deployed app in your browser
gcloud app browse
```

## How This Deployment Works

For this Snake Game, we're using a simplified approach:

1. The `deploy.sh` script builds the React client application
2. We create a minimal Express server (`server.js`) that serves the static files
3. The deployment uses a static file configuration in `app.yaml` that avoids any build steps on GCP servers
4. We use a custom `package.json` that only includes what's needed for the server

This approach ensures your game works correctly without requiring complex server-side functionality.

## Troubleshooting

### Static File Issues

If static files (JS, CSS, images) aren't loading:

1. Check the console in your browser's developer tools for 404 errors
2. Verify the file paths in the app.yaml handlers
3. Make sure all files were correctly copied to the deploy/client/dist directory

### Server Issues

If the application doesn't start:

1. Check the logs with `gcloud app logs read`
2. Make sure the server.js file is correctly set up
3. Verify that the Node.js version in app.yaml matches what's needed (nodejs20)

## Cleaning Up

To avoid unexpected charges, you can stop or delete your App Engine service when not in use:

```bash
# Disable the App Engine application
gcloud app versions stop --service=default [VERSION_ID]

# Or completely delete the application
gcloud projects delete [YOUR_PROJECT_ID]
```