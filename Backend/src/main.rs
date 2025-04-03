mod model;
mod services;
mod utils;
mod config;
mod interface;
mod controller;

use crate::config::config::load_config;
use crate::utils::Singleton;
use actix_cors::Cors;
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use interface::api;
use interface::redis::redis::RedisClient;
use redis::ConnectionLike;
use reqwest::Client;
use services::pipeline_queue::PipelineQueue;
use services::worker;
use std::sync::Arc;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    //env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("debug")).init();

    let config = load_config().unwrap();
    let singleton = Singleton::new_empty().expect("Failed to create singleton");
    singleton.init_config(config).expect("Failed to initialize singleton");
    let client = Client::new();
    singleton.init_client(client).expect("Failed to initialize client");

    let queue = PipelineQueue::new();
    singleton.init_queue(queue.clone()).unwrap_or_else(|_| {
        panic!("Failed to initialize queue");
    });

    let redis_client = RedisClient::new(singleton.config().lock().unwrap().redis.url.clone());
    singleton.init_redis(redis_client).unwrap_or_else(|_| {
        panic!("Failed to initialize client");
    });

    let shared_singleton = Arc::new(singleton);
    let web_data = web::Data::new(shared_singleton.clone());


    worker::start_worker(shared_singleton.clone());


    HttpServer::new(move || {
        App::new()
            .app_data(web_data.clone())
            .wrap(Cors::permissive())//Bypass CORS for now
            .service(
                web::scope("/api")  // All routes inside this scope will be prefixed with /api
                    .configure(api::auth::config)
                    .configure(api::uploads::config)
            )
            .default_service(web::to(not_found))
    })
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}

async fn not_found(req: actix_web::HttpRequest) -> impl Responder {
    let endpoint = req.path(); // Get the endpoint the user tried to access
    HttpResponse::NotFound().json(format!("The endpoint {} does not exist", endpoint))
}