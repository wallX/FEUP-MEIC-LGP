use std::collections::VecDeque;
use std::sync::{Arc, Mutex};

#[derive(Clone)]
pub struct PipelineQueue {
    queue: Arc<Mutex<VecDeque<String>>>,
}

impl PipelineQueue {
    pub fn new() -> Self {
        PipelineQueue {
            queue: Arc::new(Mutex::new(VecDeque::new())),
        }
    }

    pub fn print_queue(&self) {
        let queue = self.queue.lock().unwrap();
        println!("Queue: {:?}", *queue);
    }

    pub fn add_file(&self, file_name: String) {
        let mut queue = self.queue.lock().unwrap();
        queue.push_back(file_name);
    }

    pub fn next_file(&self) -> Option<String> {
        let mut queue = self.queue.lock().unwrap();
        queue.pop_front()
    }
}
