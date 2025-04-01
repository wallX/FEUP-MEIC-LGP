use std::sync::Arc;
use actix_web::{error, web, Error, HttpMessage, HttpRequest, HttpResponse};
use actix_web::dev::ServiceRequest;
use actix_web::web::{route, to};
use actix_web_httpauth::extractors::bearer::BearerAuth;
use jsonwebtoken::{decode, Validation};
use jsonwebtoken::errors::ErrorKind;
use serde::Deserialize;
use uuid::Uuid;
use crate::controller::api::auth::{extract_jwt_controller, generate_tokens, logout_user, refresh_token};
use crate::model::api::Role::Role;
use crate::model::api::jwt::{generate_jwt, validate_jwt, Claims};
use crate::model::api::user::User;
use crate::utils::Singleton;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/auth")
            .route("", web::get().to(auth))
            .route("/login", web::post().to(login))
            .route("/logout", web::post().to(logout))
            .route("/refresh", web::post().to(refresh)),
    );
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}


async fn login(data: web::Json<LoginRequest>, singleton: web::Data<Arc<Singleton>>) -> HttpResponse {
    match generate_tokens(&data.into_inner(), &singleton) {
        Ok(tokens) => HttpResponse::Ok().json(tokens),
        Err(error) => HttpResponse::InternalServerError().json(error),
    }
}
async fn logout(req: HttpRequest, singleton: web::Data<Arc<Singleton>>) -> HttpResponse {
    let (token,claims) = match extract_jwt(req.clone(), singleton.clone()) {
        Ok(token) => token,
        Err(err) => return HttpResponse::BadRequest().json(format!("{}", err)),
    };
    let refresh_token = match extract_refresh_token(req.clone()) {
        Ok(token) => token,
        Err(err) => return HttpResponse::BadRequest().json(format!("{}", err)),
    };
    match logout_user(&token, claims.exp as u64, &refresh_token, &singleton.clone()){
        Ok(resp) => HttpResponse::Ok().json(resp),
        Err(err) => HttpResponse::BadRequest().json(format!("{}", err)),
    }
}

async fn refresh(req: HttpRequest, singleton: web::Data<Arc<Singleton>>) -> HttpResponse {
    let token = match extract_refresh_token(req.clone()) {
        Ok(token) => {
            token
        }
        Err(err) => return HttpResponse::BadRequest().json(format!("{}", err)),
    };
    
    match refresh_token(&token, &singleton) {
        Ok(tokens) => HttpResponse::Ok().json(tokens),
        Err(error) => return HttpResponse::Unauthorized().json(error),
    }
}

async fn auth(req: HttpRequest, singleton: web::Data<Arc<Singleton>>) -> HttpResponse {
    match check_role(&req, Role::Admin, singleton) {
        Ok(claims) => HttpResponse::Ok().json(format!("Admin access granted to {:?}", claims.sub)),
        Err(err) => err,
    }
}

pub fn extract_jwt(req: HttpRequest, singleton: web::Data<Arc<Singleton>>) -> Result<(String,Claims), Error> {
    if let Some(auth_header) = req.headers().get("Authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            return match extract_jwt_controller(auth_str, &singleton) {
                Ok(res) => Ok(res),
                Err(err) => {
                    Err(actix_web::error::ErrorUnauthorized(err))
                }
            }
        }
    }
    Err(actix_web::error::ErrorUnauthorized("No JWT valid token found"))
}

pub fn extract_refresh_token(req: HttpRequest) -> Result<String, Error> {
    if let Some(auth_header) = req.headers().get("Refresh-Token") {
        if let Ok(auth_str) = auth_header.to_str() {
            return Ok(auth_str.to_string());
        }
    }
    Err(actix_web::error::ErrorUnauthorized("No refresh token found"))
}

// Role-based access function
pub fn check_role(req: &HttpRequest, required_role: Role, singleton: web::Data<Arc<Singleton>>) -> Result<Claims, HttpResponse> {
    match extract_jwt(req.clone(), singleton) {
        Ok((_,claims)) => {
            if claims.roles.contains(&required_role) {
                Ok(claims)
            } else {
                Err(HttpResponse::Forbidden().json("Insufficient permissions"))
            }
        }
        Err(err) => Err(err.error_response()),
    }
}
