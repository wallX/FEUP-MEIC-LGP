mod model;
mod services;
mod utils;
mod config;
mod interface;
mod controller;

use crate::utils::Singleton;
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use reqwest::Client;
use interface::api;
use services::pipeline_queue::PipelineQueue;
use services::worker;
use actix_cors::Cors;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let client = Client::new();
    let queue = PipelineQueue::new();

    worker::start_worker(queue.clone());

    //let config = &get_config().lock().unwrap();
    //println!("Main.rs {}", config.tusd.external_host);

    let singleton = web::Data::new(Singleton { client, queue });
    HttpServer::new(move || {
        App::new()
            .app_data(singleton.clone())
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