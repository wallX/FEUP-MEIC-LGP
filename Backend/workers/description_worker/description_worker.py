import redis
import os
import time
import json
import requests

# Redis connection
r = redis.Redis(host='redis', port=6379, db=0)

UPLOAD_DIR = "/app/uploads"

def wait_for_analysis_files(file_name, timeout=300, poll_interval=2):
    folder = os.path.join(UPLOAD_DIR, f"{file_name}_analysis")
    transcription_path = os.path.join(folder, f"{file_name}_transcription.json")
    captions_path = os.path.join(folder, f"{file_name}_captions.json")

    elapsed = 0
    while elapsed < timeout:
        if os.path.isfile(transcription_path) and os.path.isfile(captions_path):
            return transcription_path, captions_path
        time.sleep(poll_interval)
        elapsed += poll_interval

    raise TimeoutError(f"Timeout waiting for transcription and captions for {file_name}")

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def format_prompt(transcription, captions):
    caption_text = "\n".join([f"Frame {c['frame']}: {c['caption']}" for c in captions])
    prompt = (
        "I am going to give you the full transcription of a video, and a description of each frame per second."
        "Keep in mind that there might be several captions with misleading information, you must recognize the correct captions with the help of the transcription. With this information, summarize the video.\n\n"
        f"Transcription:\n{transcription}\n\nCaptions:\n{caption_text}"
    )
    return prompt

def query_llamacpp(prompt, model="llama"):
    url = "http://llamacpp-server:8080/v1/completions"
    headers = {"Content-Type": "application/json"}
    payload = {
        "model": model,
        "prompt": prompt,
        "max_tokens": 512,
        "temperature": 0.7,
    }

    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()["choices"][0]["text"]

def save_summary(file_name, summary):
    folder = os.path.join(UPLOAD_DIR, f"{file_name}_analysis")
    output_path = os.path.join(folder, f"{file_name}_description.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump({"summary": summary.strip()}, f, indent=2)
    print(f"Saved summary to {output_path}")

def process_job(file_name):
    print(f"Waiting for analysis files for: {file_name}")
    try:
        transcription_path, captions_path = wait_for_analysis_files(file_name)
        transcription = load_json(transcription_path)["transcription"]
        captions = load_json(captions_path)["captions"]
        prompt = format_prompt(transcription, captions)
        summary = query_llamacpp(prompt)
        save_summary(file_name, summary)
        r.decr(f"pending:{file_name}")
    except Exception as e:
        print(f"Failed to process summary for {file_name}: {e}")

def listen_for_jobs():
    print("Worker is listening for jobs on 'description_queue'...")
    while True:
        job = r.blpop('description_queue', timeout=5)
        if job:
            _, file_name = job
            file_name = file_name.decode()
            print(f"Processing job: {file_name}")
            process_job(file_name)
        else:
            print("No job found, waiting...")

if __name__ == "__main__":
    listen_for_jobs()
