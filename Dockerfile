# Use the official Python image
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the app code and templates
COPY app.py .
COPY templates/ templates/

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
