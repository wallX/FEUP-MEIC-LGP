# Video Processing Pipeline Overview

This document outlines the high-level workflow of how uploaded videos are processed in the system.

## 1. Upload & Queueing

When a video is uploaded:

- The file name is added to an in-memory queue (`PipelineQueue`).
- This queue is managed using a thread-safe `VecDeque`.

## 2. Worker Execution

A background worker (`start_worker`) continuously polls the queue:

- If a video is found, it spawns an async task to process it.
- Each video is handled independently in a separate task.

## 3. Processing Steps

The `process_file` function runs the pipeline for each file:

- Initializes Redis tracking for the file.
- Creates a folder for analysis output.
- Sends tasks to Redis work queues (e.g., `caption_queue`, `video_image_description`).
- Waits for task completion via Redis pub/sub.

## 4. Task Coordination (Redis)

- Tasks publish their completion using Redis channels.
- The system waits for the `"completed:<filename>"` message before finalizing.

 # 🧪 Adding a New Type of Analysis to the Pipeline (External Agent + Redis)

 This guide explains how to add a new analysis type to the video processing pipeline using Redis for queueing and communication with an external agent.

 ---

 ## ✅ Prerequisites

 - A Redis instance is up and running.
 - You have access to the codebase for both the pipeline and the external agent.
 - The external agent can consume messages from a Redis queue and publish to a Redis channel.

 ---

 ## 1. Create a Redis Queue for the New Analysis

 Choose a unique name for the new Redis queue, e.g., `new_analysis_queue`.

 No changes needed in Redis directly—just use the queue name consistently in both producer (pipeline) and consumer (agent).

 ---

 ## 2. Add the Task to the Pipeline

 In `pipeline.rs` or wherever tasks are dispatched:

 ```rust
 // Add this line in process_file or wherever tasks are queued
 new_analysis(file_name.clone(), &singleton).await;
 ```

 Define the function like this:

 ```rust
 pub async fn new_analysis(file_name: String, singleton: &AppStateSingleton) {
     singleton
         .redis()
         .send_to_queue("new_analysis_queue", &file_name)
         .await;
 }
 ```

 ---

 ## 3. Update the External Agent to Listen to the Queue

 In the agent code:

 - Subscribe to `new_analysis_queue`
 - On receiving a filename, process the video accordingly
 - After processing, **decrement a Redis counter**
 - If the counter reaches zero, publish the `"completed:<filename>"` message

 Example pseudocode:

 ```python
 # Pseudocode (Python style)
 while True:
     file_name = redis.blpop("new_analysis_queue")
     result = run_new_analysis(file_name)

     # Decrement the task counter
     remaining = redis.decr(f"pending:{file_name}")

     # If this was the last task, notify the worker
     if remaining == 0:
         redis.publish(f"completed:{file_name}", "all_tasks_done")
 ```

 You must ensure the counter is properly **initialized** in the pipeline before any tasks are queued.