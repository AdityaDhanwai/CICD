#!/bin/bash
# Ensure the script exits if any command fails
set -e

# Install required dependencies for the virtual environment
sudo apt update
sudo apt install -y python3.12-venv python3-pip

# Navigate to the app directory
cd /home/ubuntu/EasyScheduler01

# Ensure the ownership of the app directory is correct
sudo chown -R ubuntu:ubuntu /home/ubuntu/EasyScheduler01

# Create the virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Upgrade pip to the latest version
pip install --upgrade pip

# Install dependencies from requirements.txt
echo "Installing dependencies from requirements.txt..."
pip install --no-cache-dir -r requirements.txt --break-system-packages

# Ensure Gunicorn is installed
if ! pip freeze | grep -q gunicorn; then
    echo "Gunicorn not found in venv, installing..."
    pip install gunicorn
fi

# Stop any running Gunicorn processes
if pgrep gunicorn > /dev/null; then
    echo "Stopping existing Gunicorn processes..."
    pkill gunicorn
fi

# Start the Flask application using Gunicorn
echo "Starting the Flask application using Gunicorn..."
gunicorn -b 0.0.0.0:8000 app:app --daemon

# Restart Nginx to apply the latest changes
sudo systemctl restart nginx

echo "Application started successfully."
