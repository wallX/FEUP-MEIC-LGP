use crate::utils::Singleton;
use actix_web::{web, HttpRequest, HttpResponse};
use serde_json::Value;
use std::path::Path;
use base64::{engine::general_purpose, Engine as _};
use crate::config::config::get_config;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/uploads")
            .route(web::post().to(initiate_upload)),
    )
        .service(
            web::resource("/uploads/hook")
                .route(web::post().to(upload_ready_hook)),
        );
}


async fn initiate_upload(req: HttpRequest, singleton: web::Data<Singleton>) -> HttpResponse {
    let client = &singleton.client;
    let config = get_config().lock().unwrap();

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
        general_purpose::STANDARD.encode(file_name.clone()),
        general_purpose::STANDARD.encode(file_extension),
        general_purpose::STANDARD.encode(user)
    );

    match client
        .post(&config.tusd.url)
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

async fn upload_ready_hook(body: web::Json<Value>) -> HttpResponse {
    let json_data = body.into_inner();

    // Navigate through the JSON structure safely
    let id = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("ID"))
        .and_then(|id| id.as_str())
        .unwrap_or("Unknown ID");

    let filename = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("MetaData"))
        .and_then(|md| md.get("filename"))
        .and_then(|fnm| fnm.as_str())
        .unwrap_or("Unknown filename");

    let username = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("MetaData"))
        .and_then(|md| md.get("username"))
        .and_then(|usr| usr.as_str())
        .unwrap_or("Unknown username");

    println!("Upload ID: {}", id);
    println!("Upload Name: {}", filename);
    println!("Upload Username: {}", username);

    // Return extracted values as JSON response
    HttpResponse::Ok().json(serde_json::json!({
        "ID": id,
        "filename": filename,
        "username": username
    }))



}
