FROM python:3.10-slim

# Install system dependencies if needed
RUN apt-get update && apt-get install -y \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Install required Python packages
RUN pip install requests --no-cache-dir

RUN pip install redis --no-cache-dir

RUN pip install google-generativeai --no-cache-dir
# Set working directory
WORKDIR /app

# Copy the description worker script into the container
COPY description_worker.py .

# Define entrypoint
ENTRYPOINT ["python", "description_worker.py"]
