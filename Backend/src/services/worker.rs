use std::sync::Arc;
use std::thread;
use crate::services::pipeline_queue::PipelineQueue;
use crate::services::process_file;
use crate::utils::Singleton;

pub fn start_worker(singleton: Arc<Singleton>) {
    thread::spawn(move || {
        loop {
            if let Some(file_name) = singleton.queue().next_file() {
                println!("Worker processing {}", file_name);
                process_file(file_name);
            } else {
                // Sleep for a short time to avoid busy-waiting
                thread::sleep(std::time::Duration::from_secs(1));
            }
        }
    });
}
