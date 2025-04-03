use crate::services::process_file;
use crate::utils::Singleton;
use std::sync::Arc;

pub fn start_worker(singleton: Arc<Singleton>) {
    tokio::spawn(async move {
        loop {
            // Clone the Arc before the inner spawn
            let singleton_clone = singleton.clone();

            if let Some(file_name) = singleton_clone.queue().next_file() {

                tokio::spawn(async move {
                    println!("processing for: {}", file_name);
                    process_file(file_name, singleton_clone).await;
                });

            } else {
                // Sleep for a short time to avoid busy-waiting
                tokio::time::sleep(std::time::Duration::from_secs(1)).await;
            }
        }
    });
}
