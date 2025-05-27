# Use an official PyTorch base image with CUDA (or CPU if you prefer)
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    ffmpeg \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies directly
RUN pip install --no-cache-dir \
    torch \
    torchvision \
    opencv-python-headless \
    pyiqa \
    redis \
    tqdm \
    Pillow


WORKDIR /app

# Copy the application code into the container
COPY video_quality_worker.py .

# Set the entrypoint
CMD ["python", "video_quality_worker.py"]
