mod model;
mod services;
mod utils;
mod config;
mod interface;
mod controller;

use crate::utils::Singleton;
use actix_web::{web, App, HttpServer};
use reqwest::Client;
use interface::api;
use services::pipeline_queue::PipelineQueue;
use services::worker;




#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let client = Client::new();
    let queue = PipelineQueue::new();

    worker::start_worker(queue.clone());

    let singleton = web::Data::new(Singleton { client, queue });
    HttpServer::new(move || {
        App::new()
            .app_data(singleton.clone())
            .configure(api::auth::config)
            .configure(api::uploads::config)
    })
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}