import redis
import os
import json
import torch
import cv2
import pyiqa
from tqdm import tqdm
import torchvision.transforms as transforms

# Redis connection
r = redis.Redis(host='redis', port=6379, db=0)

# Setup IQA metric
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
iqa_metric = pyiqa.create_metric('dbcnn', device=device)

# Transform for the frames
transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor()
])

UPLOAD_DIR = "/app/uploads"

def extract_frames(video_path, max_frames=50):
    cap = cv2.VideoCapture(video_path)
    frames = []
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    step = max(total_frames // max_frames, 1)

    for i in range(0, total_frames, step):
        cap.set(cv2.CAP_PROP_POS_FRAMES, i)
        ret, frame = cap.read()
        if not ret:
            break
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        frames.append(rgb_frame)
        if len(frames) >= max_frames:
            break
    cap.release()
    return frames

def get_video_quality_score(video_path, max_frames=50):
    frames = extract_frames(video_path, max_frames)
    print(f"Extracted {len(frames)} frames from {video_path}")

    scores = []
    for frame in tqdm(frames, desc=f"Scoring {video_path}"):
        tensor = transform(frame).unsqueeze(0).to(device)
        score = iqa_metric(tensor)
        scores.append(score.item())
    return sum(scores) / len(scores)

def categorize_quality(score):
    if score >= 0.8:
        return "Excellent"
    elif score >= 0.6:
        return "Good"
    elif score >= 0.4:
        return "Fair"
    elif score >= 0.2:
        return "Poor"
    else:
        return "Very Poor"

def save_result(file_name, score, category):
    result_dir = os.path.join(UPLOAD_DIR, f"{file_name}_analysis")
    os.makedirs(result_dir, exist_ok=True)
    with open(os.path.join(result_dir, f"{file_name}_quality.json"), "w") as f:
        json.dump({"score": score, "category": category}, f, indent=2)
    print(f"Saved quality results to {file_name}_quality.json")

def process_video(file_name):
    video_path = os.path.join(UPLOAD_DIR, file_name)
    if not os.path.isfile(video_path):
        print(f"File not found: {video_path}")
        return
    try:
        score = get_video_quality_score(video_path)
        category = categorize_quality(score)
        save_result(file_name, score, category)
        r.decr(f"pending:{file_name}")
    except Exception as e:
        print(f"Error processing {file_name}: {e}")

def listen_for_jobs():
    print("Video Quality Worker is listening on 'quality_queue'...")
    while True:
        job = r.blpop('quality_queue', timeout=5)
        if job:
            _, file_name = job
            file_name = file_name.decode()
            print(f"Processing job: {file_name}")
            process_video(file_name)
        else:
            print("No job found, waiting...")

if __name__ == "__main__":
    listen_for_jobs()
