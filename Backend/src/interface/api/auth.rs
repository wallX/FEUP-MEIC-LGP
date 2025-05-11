use crate::controller::api::auth::{extract_jwt_controller, generate_tokens, logout_user, refresh_token};
use crate::model::api::jwt::Claims;
use crate::model::api::role::Role;
use crate::utils::Singleton;
use actix_web::{web, Error, HttpMessage, HttpRequest, HttpResponse};
use serde::Deserialize;
use std::sync::Arc;

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
    let (token,claims) = match extract_jwt(req.clone(),false, singleton.clone()) {
        Ok(token) => token,
        Err(err) => return err,
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
    let refresh_token_string = match extract_refresh_token(req.clone()) {
        Ok(token) => {
            token
        }
        Err(err) => return HttpResponse::BadRequest().json(format!("{}", err)),
    };

    let (token,claim) = match extract_jwt(req.clone(),false, singleton.clone()) {
        Ok(token) => token,
        Err(err) => return err,
    };
    
    match refresh_token(&refresh_token_string,&claim, &token, &singleton) {
        Ok(tokens) => HttpResponse::Ok().json(tokens),
        Err(error) => return HttpResponse::Unauthorized().json(error),
    }
}

async fn auth(req: HttpRequest, singleton: web::Data<Arc<Singleton>>) -> HttpResponse {

    let role_header = req.headers().get("User-Role");
    let role_str = match role_header {
        Some(value) => match value.to_str() {
            Ok(str) => str,
            Err(_) => return HttpResponse::BadRequest().insert_header(("Auth-Message", "Invalid role header format")).json("Invalid role header format"),
        },
        None => return HttpResponse::BadRequest().insert_header(("Auth-Message", "Missing role header")).json("Missing role header"),
    };

    // Convert string to Role enum
    let required_role = match role_str.parse::<Role>() {
        Ok(role) => role,
        Err(_) => return HttpResponse::BadRequest().insert_header(("Auth-Message", "Invalid role value")).json("Invalid role value"),
    };
    
    
    
    
    
    match check_role(&req, required_role.clone(), singleton) {
        Ok(claims) => HttpResponse::Ok().json(format!("Role {:?} access granted to {:?}", required_role,claims.sub)),
        Err(err) => err,
    }
}

pub fn extract_jwt(req: HttpRequest, validate: bool, singleton: web::Data<Arc<Singleton>>) -> Result<(String,Claims), HttpResponse> {
    if let Some(auth_header) = req.headers().get("Authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            return match extract_jwt_controller(auth_str, &singleton, Option::from(validate)) {
                Ok(res) => Ok(res),
                Err(err) => {
                    Err(HttpResponse::Unauthorized().json(err.to_string()))
                }
            }
        }
    }
    Err(HttpResponse::Unauthorized().json("No JWT valid token found".to_string()))
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
    match extract_jwt(req.clone(),true, singleton) {
        Ok((_,claims)) => {
            if claims.roles.contains(&required_role) {
                Ok(claims)
            } else {
                Err(HttpResponse::Forbidden().json("Insufficient permissions"))
            }
        }
        Err(err) => Err(err),
    }
}
