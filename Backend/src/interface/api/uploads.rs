use crate::utils::Singleton;
use crate::{controller};
use crate::model::api::uploads::UploadRequest;
use actix_web::{web, HttpRequest, HttpResponse};
use serde_json::Value;


pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/uploads")
            .route(web::post().to(initiate_upload))
            .route(web::get().to(get_uploads)),
    )
        .service(
            web::resource("/uploads/hook")
                .route(web::post().to(upload_ready_hook)),
        );
}


async fn initiate_upload(req: HttpRequest, singleton: web::Data<Singleton>) -> HttpResponse {
    let upload_request = match UploadRequest::from_headers(req) {
        Ok(request) => request,
        Err(error_response) => return error_response
    };

    match controller::api::uploads::initiate_upload_logic(upload_request, &singleton).await {
        Ok(response) => {
            let mut http_response_builder = HttpResponse::build(
                actix_web::http::StatusCode::from_u16(response.status).unwrap()
            );

            for (key, value) in response.headers {
                http_response_builder.append_header((key.as_str(), value));
            }

            http_response_builder.finish()
        },
        Err(error_response) => return HttpResponse::InternalServerError().json(error_response),
    }
}


impl UploadRequest {
    fn from_headers(req: HttpRequest) -> Result<Self, HttpResponse> {
        let headers = req.headers();
        let file_name = headers
            .get("file_name")
            .and_then(|v| v.to_str().ok())
            .map(|s| s.to_string())
            .ok_or_else(|| HttpResponse::BadRequest().json("Missing 'file_name' header"))?;

        let file_length = headers
            .get("file_length")
            .and_then(|v| v.to_str().ok())
            .and_then(|s| s.parse::<u64>().ok())
            .ok_or_else(|| HttpResponse::BadRequest().json("Missing or invalid 'file_length' header"))?;

        if file_length < 1 {
            return Err(HttpResponse::BadRequest().json("Invalid 'file_length' value"));
        }

        Ok(Self { file_name, file_length })
    }
}

async fn get_uploads(singleton: web::Data<Singleton>) -> HttpResponse {
    println!("Getting uploaded files");
    HttpResponse::Ok().json("Service is up and running")
}


async fn upload_ready_hook(
    body: web::Json<Value>,
    singleton: web::Data<Singleton>,
) -> HttpResponse {
    HttpResponse::Ok().json(controller::api::uploads::upload_ready_hook_logic(body.into_inner(), &singleton).await)
}

