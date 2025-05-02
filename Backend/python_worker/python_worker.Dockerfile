FROM python:3.10-slim

# Install system-level dependencies required by Whisper and ffmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install only the required Python packages
RUN pip install --upgrade pip

# Install Whisper (includes NumPy and PyTorch CPU build)
RUN pip install openai-whisper --no-cache-dir

RUN pip install redis --no-cache-dir

# Set working directory
WORKDIR /app

# Add your Python script
COPY video_worker.py .

# Define entrypoint
ENTRYPOINT ["python", "video_worker.py"]