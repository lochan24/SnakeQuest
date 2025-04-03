Running the Snake Game on a GCP VM Instance
To run this project on a GCP VM instance (rather than App Engine), follow these steps:

1. Create a VM Instance on GCP
  Go to the Google Cloud Console
  Navigate to Compute Engine > VM instances
  Click "Create Instance"
  Configure your VM:
  Choose a name for your instance
  Select a region and zone
  Choose a machine type (e2-micro is fine for this project)
  Select a boot disk (Ubuntu 20.04 or later recommended)
  Under "Firewall", check "Allow HTTP traffic" and "Allow HTTPS traffic"
  Click "Create"

2. Connect to Your VM
  In the VM instances list, click the "SSH" button next to your instance
  This will open a terminal window connected to your VM

3. Install Dependencies
  In the SSH terminal, run:
  # Update package lists
  sudo apt-get update
  # Install Node.js (version 20.x)
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
  # Install Git
  sudo apt-get install -y git
  # Verify installations
  node -v
  npm -v
  git --version

4. Clone and Run the Project
  Option 1: Clone from GitHub (if your project is on GitHub)
    # Clone your repository
    git clone YOUR_GITHUB_REPO_URL
    cd your-repo-name
    # Install dependencies
    npm install
    # Start the server
    npm run dev
 
  Option 2: Upload the Simplified Version
    Run the simplified deploy script on your local machine:
    
    ./simplified-gcp-deploy.sh
    Transfer the gcp-simplified directory to your VM:
    
    You can use gcloud compute scp command
    Or create a ZIP file and upload it through the browser-based SSH terminal
    On the VM, run:
    
    cd gcp-simplified
    npm install
    npm start
5. Configure Firewall Rules
  If your application is running but not accessible, you may need to open the port:
  # Allow traffic on port 8080 (or whatever port your app uses)
  sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
6. Access Your Application
  Your application should now be accessible at:
  
  http://YOUR_VM_EXTERNAL_IP:8080
  You can find your VM's external IP in the Google Cloud Console under VM instances.

7. Setup for Persistent Running (Optional)
  To keep your application running after you close the SSH session:
  # Install PM2
  sudo npm install -g pm2
  # Start your application with PM2
  cd gcp-simplified  # or your project directory
  pm2 start server.js
  # Set PM2 to start on boot
  pm2 startup
  # Run the command that PM2 outputs
  # Save the PM2 configuration
  pm2 save
  This will ensure your Snake game continues running even if you disconnect from the SSH session or if the VM restarts.
