use actix_web::{web, HttpResponse};

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/auth/login")
            .route(web::post().to(login)),
    );
}

async fn login() -> HttpResponse {
    // Handle login logic
    HttpResponse::Ok().json("Logged in!")
}