use std::thread;
use crate::services::pipeline_queue::PipelineQueue;
use crate::services::process_file;

pub fn start_worker(queue: PipelineQueue) {
    thread::spawn(move || {
        loop {
            if let Some(file_name) = queue.next_file() {
                println!("Worker processing {}", file_name);
                process_file(file_name);
            } else {
                // Sleep for a short time to avoid busy-waiting
                thread::sleep(std::time::Duration::from_secs(1));
            }
        }
    });
}
