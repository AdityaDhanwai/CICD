#!/bin/bash
# Ensure script fails if any command fails
# set -e
sudo apt install python3.12-venv
# Navigate to the app directory
cd /home/ubuntu/EasyScheduler01

# Activate the virtual environment
source venv/bin/activate

# Add local bin to PATH
export PATH=$PATH:/home/ubuntu/.local/bin
# Change the owner of the venv to your current user
sudo chown -R ubuntu:ubuntu /home/ubuntu/EasyScheduler01/venv
# Install dependencies from requirements.txt
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Check if gunicorn is installed, install if not
if ! pip3 freeze | grep -q gunicorn; then
    echo "Gunicorn not found in venv, installing..."
    pip3 install gunicorn
fi

pgrep gunicorn && pkill gunicorn
# Start the Flask application using Gunicorn
echo "Starting the Flask application using Gunicorn..."
gunicorn -b 0.0.0.0:8000 app:app --daemon
sudo systemctl restart nginx
