import redis
import whisper
import time
import json
import os

# Redis connection
r = redis.Redis(host='redis', port=6379, db=0)

# Load Whisper model once
transcription_model = whisper.load_model("small")

# Paths
UPLOAD_DIR = "/app/uploads"
VIDEO_PATH_TEST = "test.mp4"

def transcribe_video(video_path):
    print(f"Transcribing: {video_path}")
    result = transcription_model.transcribe(video_path)
    return result["text"]

def save_transcription(file_name, text):
    output_path = os.path.join(UPLOAD_DIR, f"{file_name}_transcription.json")
    with open(output_path, "w") as f:
        json.dump({"transcription": text}, f, indent=2)
    print(f"Saved transcription to {output_path}")


def process_video(file_name):
    original_path = os.path.join(UPLOAD_DIR, VIDEO_PATH_TEST)
    print(original_path)
    if not os.path.isfile(original_path):
        print(f"File not found: {original_path}")
        return

    try:
        transcription = transcribe_video(original_path)
        save_transcription(file_name, transcription)
        r.decr(f"pending:{file_name}")
    except Exception as e:
        print(f"Failed to transcribe {file_name}: {e}")

def listen_for_jobs():
    print("Worker is listening for jobs on 'transcription_queue'...")
    while True:
        job = r.blpop('transcription_queue', timeout=5)
        if job:
            _, file_name = job
            file_name = file_name.decode()
            print(f"Processing job: {file_name}")
            process_video(file_name)
        else:
            print("No job found, waiting...")

if __name__ == "__main__":
    listen_for_jobs()
