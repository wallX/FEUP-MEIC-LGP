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
