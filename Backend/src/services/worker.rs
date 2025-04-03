use crate::services::process_file;
use crate::utils::Singleton;
use std::sync::Arc;

pub fn start_worker(singleton: Arc<Singleton>) {
    tokio::spawn(async move {
        loop {
            // Clone the Arc before the inner spawn
            let singleton_clone = singleton.clone();

            if let Some(file_name) = singleton_clone.queue().next_file() {

                println!("Spawning processing task for: {}", file_name.clone());

                tokio::spawn(async move {
                    println!("Processing file: {}", file_name.clone());

                    let file_name_for_logging = file_name.clone(); // Clone before moving

                    let result = tokio::task::spawn_blocking(move || {
                        tokio::runtime::Handle::current().block_on(async move {
                            process_file(file_name, singleton_clone).await;
                        })
                    }).await;

                    if let Err(e) = result {
                        eprintln!("Error processing file {}: {:?}", file_name_for_logging, e);
                    }
                });

            } else {
                // Sleep for a short time to avoid busy-waiting
                tokio::time::sleep(std::time::Duration::from_secs(1)).await;
            }
        }
    });
}
