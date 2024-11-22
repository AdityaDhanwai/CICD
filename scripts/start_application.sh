#!/bin/bash
set -e

# Update system packages
sudo apt update
sudo apt install -y python3.12-venv python3-pip curl

# Navigate to the application directory
cd /home/ubuntu/EasyScheduler01

# Ensure the ownership of the app directory is correct
sudo chown -R ubuntu:ubuntu /home/ubuntu/EasyScheduler01

# Remove the existing virtual environment if it exists
if [ -d "venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf venv
fi

# Create a new virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install pip manually if needed
if [ ! -f "venv/bin/pip" ]; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py | python
fi

# Upgrade pip, setuptools, and wheel
pip install --upgrade pip setuptools wheel

# Verify virtual environment setup
echo "Python version: $(python --version)"
echo "Pip version: $(pip --version)"
echo "Virtual environment path: $(which python)"

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install --no-cache-dir -r requirements.txt

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
