use reqwest::Client;
use crate::services::pipeline_queue::PipelineQueue;

pub struct Singleton {
    pub client: Client,
    pub queue: PipelineQueue
}