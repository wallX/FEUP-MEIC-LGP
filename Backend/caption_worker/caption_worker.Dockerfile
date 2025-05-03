FROM python:3.10-slim

# Install system dependencies for OpenCV and image processing
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgl1 \
    git \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Install required Python packages
RUN pip install \
    transformers \
    torch \
    pillow \
    opencv-python-headless \
    redis \
    --no-cache-dir

# Set working directory
WORKDIR /app

# Copy the caption worker script into the container
COPY caption_worker.py .

# Define entrypoint
ENTRYPOINT ["python", "caption_worker.py"]
