use crate::utils::Singleton;
use std::fs;
use std::sync::Arc;
use std::thread::sleep;
use std::time::Duration;

async fn make_analysis_folder(file_name: &str, singleton: Arc<Singleton>) {
    let path = format!("uploads/{}_analysis", file_name);
    fs::create_dir(path).expect("fail to create folder");
}

fn transcode_video(file_name: &str, singleton: Arc<Singleton>) {
    println!("Transcoding video: {}", file_name);
    sleep(Duration::new(5, 0));
}

async fn transcribe_video(file_name: &str, singleton: Arc<Singleton>) {
    println!("Transcribing video: {}", file_name);
    singleton.redis().send_to_work_queue("transcription_queue", file_name).await.expect("OH NO: panic message");
}

async fn caption_video_frames(file_name: &str, singleton: Arc<Singleton>) {
    println!("Captioning video frames: {}", file_name);
    singleton.redis().send_to_work_queue("caption_queue", file_name).await.expect("OH NO: panic message");
}

async fn description_video(file_name: &str, singleton: Arc<Singleton>) {
    println!("Generating desciption for video: {}", file_name);
    singleton.redis().send_to_work_queue("description_queue", file_name).await.expect("OH NO: panic message");
}

fn store_results(file_name: &str, arc: Arc<Singleton>) {
    println!("Storing results for  {}", file_name);
    // Add storage logic here
}

fn clean_files(file_name: &str, arc: Arc<Singleton>) {
    println!("Cleaning files: {}", file_name);
}


pub async fn process_file(file_name: String, singleton: Arc<Singleton>) {
    println!("Processing file: {}", file_name);
    singleton.redis().initiate_queue(file_name.as_str()).await.expect("OH NO: panic message");

    make_analysis_folder(&file_name, singleton.clone()).await;

    transcribe_video(&file_name,singleton.clone()).await;
    caption_video_frames(&file_name,singleton.clone()).await;
    description_video(&file_name,singleton.clone()).await;

    singleton.redis().listen_for_completion(&file_name).await.expect("TODO: panic message");
    println!("Processing complete for: {}", file_name);
}