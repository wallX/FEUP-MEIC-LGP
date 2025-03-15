use actix_web::{web, App, HttpServer};
use reqwest::Client;
use crate::utils::Singleton;

mod api;
mod models;
mod services;
mod utils;
mod config;



#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let client = Client::new();

    let singleton = web::Data::new(Singleton { client });
    HttpServer::new(move || {
        App::new()
            .app_data(singleton.clone())
            .configure(api::auth::config)
            .configure(api::uploads::config)
    })
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}