use std::collections::HashMap;
use std::path::Path;
use actix_web::{web, HttpRequest, HttpResponse};
use crate::config::get_config;
use crate::models::UploadRequest;
use crate::utils::Singleton;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/uploads")
            .route(web::post().to(initiate_upload))
            .route(web::get().to(upload_hook)),
    );
}


async fn initiate_upload(req: HttpRequest, singleton: web::Data<Singleton>) -> HttpResponse {
    let client = &singleton.client;

    /*let config = get_config().lock().unwrap();
    println!("Tusd URL: {}", config.tusd.url);
    println!("Upload Path: {}", config.tusd.upload_path);*/

    // Extract headers
    let file_name = match req.headers().get("file_name") {
        Some(value) => value.to_str().unwrap_or("").to_string(),
        None => return HttpResponse::BadRequest().json("Missing 'file_name' header"),
    };

    let file_length = match req.headers().get("file_length") {
        Some(value) => value.to_str().unwrap_or("0").parse::<u64>().unwrap_or(0),
        None => return HttpResponse::BadRequest().json("Missing 'file_length' header"),
    };

    // Validate file_length
    if file_length < 1 {
        return HttpResponse::BadRequest().json("Invalid 'file_length' value");
    }

    let file_extension = Path::new(&file_name).extension().unwrap().to_str().unwrap();
    let user = "alex";

    let metadata = format!(
        "filename {},extension {},username {}",
        base64::encode(file_name.clone()),
        base64::encode(file_extension.clone()),
        base64::encode(user)
    );

    match client
        .post("http://localhost:1080/files")
        .header("Upload-Length", file_length.to_string())
        .header("Tus-Resumable", "1.0.0")
        .header("Upload-Metadata", metadata) // Add metadata
        .send()
        .await
    {
        Ok(response) => {
        if response.status().is_success() {
            //let headers: HashMap<String, String> = response.headers().iter()
            //    .map(|(k, v)| (k.to_string(), v.to_str().unwrap()
            //        .to_string())).collect();
            let mut http_response_builder = HttpResponse::Ok();
            for (key, value) in response.headers().iter() {
                http_response_builder.append_header((key.as_str(), value.to_str().unwrap()));
            }
            http_response_builder.finish()
        } else {
            HttpResponse::InternalServerError().json("Failed to initiate upload")
        }
    }
        Err(_) => HttpResponse::InternalServerError().json("Failed to send request to tusd"),
    }
}

async fn upload_hook() -> HttpResponse {
    HttpResponse::Ok().json("Upload status: Pending")
}