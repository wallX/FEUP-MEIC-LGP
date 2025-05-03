import redis
import time
import json
import os
import cv2
from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration

# Redis connection
r = redis.Redis(host='redis', port=6379, db=0)

# Paths
UPLOAD_DIR = "/app/uploads"
VIDEO_PATH_TEST = "test.mp4"

# Globals for processor and model, initialized later
processor = None
image_caption_model = None

def extract_frames_from_video(video_path, fps=1):
    cap = cv2.VideoCapture(video_path)
    frame_rate = int(cap.get(cv2.CAP_PROP_FPS))
    frame_interval = max(1, int(frame_rate / fps))

    frame_count = 0
    frames = []

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        if frame_count % frame_interval == 0:
            frames.append((frame_count, frame))
        frame_count += 1

    cap.release()
    return frames

def caption_frame_array(frame):
    image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    inputs = processor(image, return_tensors="pt")
    out = image_caption_model.generate(**inputs)
    caption = processor.decode(out[0], skip_special_tokens=True)
    return caption

def caption_video(video_path):
    captions = []
    frames = extract_frames_from_video(video_path)
    for idx, (frame_idx, frame) in enumerate(frames):
        caption = caption_frame_array(frame)
        captions.append({
            "frame": idx,
            "caption": caption
        })
    return captions

def save_captions(file_name, captions):
    final_upload_dir = os.path.join(UPLOAD_DIR, f"{file_name}_analysis")
    os.makedirs(final_upload_dir, exist_ok=True)
    output_path = os.path.join(final_upload_dir, f"{file_name}_captions.json")
    with open(output_path, "w") as f:
        json.dump({"captions": captions}, f, indent=2)
    print(f"Saved captions to {output_path}")

def process_video(file_name):
    original_path = os.path.join(UPLOAD_DIR, VIDEO_PATH_TEST)
    if not os.path.isfile(original_path):
        print(f"File not found: {original_path}")
        return

    try:
        captions = caption_video(original_path)
        save_captions(file_name, captions)
        r.decr(f"pending:{file_name}")
    except Exception as e:
        print(f"Failed to caption {file_name}: {e}")

def listen_for_jobs():
    print("Worker is listening for jobs on 'caption_queue'...")
    while True:
        job = r.blpop('caption_queue', timeout=5)
        if job:
            _, file_name = job
            file_name = file_name.decode()
            print(f"Processing job: {file_name}")
            process_video(file_name)
        else:
            print("No job found, waiting...")

if __name__ == "__main__":
    import multiprocessing
    multiprocessing.freeze_support()

    # Load models here to avoid multiprocessing issues on Windows
    processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
    image_caption_model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

    listen_for_jobs()
