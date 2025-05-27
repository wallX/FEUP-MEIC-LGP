use crate::interface::api::auth::LoginRequest;
use crate::model::api::jwt::{decode_expired_jwt, generate_jwt, validate_jwt, Claims};
use crate::model::api::user;
use crate::model::api::role::Role;
use crate::utils::password_util::{hash_password, verify_password};
use crate::utils::Singleton;
use chrono::{Duration, Utc};
use jsonwebtoken::errors::ErrorKind;
use uuid::Uuid;

pub fn extract_jwt_controller (auth_str: &str, singleton: &Singleton, validate: Option<bool>) -> Result<(String,Claims), String> {
    let secret = singleton.config().lock().unwrap().jwt.token.clone();
    let validate = validate.unwrap_or(true);
    if auth_str.starts_with("Bearer ") {
        let token = &auth_str[7..];
        match singleton.redis().check_jwt(token) {
            Ok(false) => return Err("JWT is blacklisted".to_string()),
            Ok(_) => {},
            Err(_) => return Err("Failed to check JWT blacklist".to_string()),
        };

        return match (validate, validate_jwt(token, &secret), decode_expired_jwt(token, &secret)) {
            (true, Ok(claims), _) | (false, _, Ok(claims)) => Ok((token.parse().unwrap(), claims)),
            (_, Err(err), _) | (_, _, Err(err)) => match *err.kind() {
                ErrorKind::ExpiredSignature => Err(String::from("JWT expired")),
                _ => Err(String::from("Invalid JWT")),
            },
        };
        
         
    }
    Err(String::from("Token Error Controller"))
}


pub async fn validate_user_login(email: String, password: String, singleton: &Singleton) -> Result<user::User, String> {
    
    // fetch user from db
    let u = user::get_user_by_email(singleton.postgres(), &email).await.unwrap();
    
    // Password hasher
    if email == u.email && verify_password(password.as_ref(), u.password_hash.as_ref()) {
        return Ok(u);
    } 
    Err(String::from("Invalid email or password"))
}

pub async fn generate_tokens_and_login_info(login: &LoginRequest, singleton: &Singleton) -> Result<serde_json::value::Value, String> {
    
    let user = match validate_user_login(login.email.clone(), login.password.clone(), singleton).await {
        Ok(user) => user,
        Err(err) => return Err(err),
    };
    
    let secret = singleton.config().lock().unwrap().jwt.token.clone();
    let token_ttl = singleton.config().lock().unwrap().jwt.token_ttl;
    let refresh_token_ttl = singleton.config().lock().unwrap().jwt.refresh_token_ttl;
    
    let jwt = match generate_jwt(user.id, user.roles.clone(), &secret, token_ttl) {
        Ok(token) => token,
        Err(_) => return Err(String::from("Failed to generate JWT token")),
    };

    // Generate refresh token (UUID for simplicity)
    let refresh_token = Uuid::new_v4();
    let expiration = Utc::now()
        .checked_add_signed(Duration::days(refresh_token_ttl))
        .expect("valid timestamp")
        .timestamp() as usize;
    //Add token to redis
    
    singleton.redis().refresh_token(&refresh_token.to_string(), &user.id.clone().to_string(), expiration as u64).unwrap();
    Ok(
        serde_json::json!(
            {
                "token": jwt,
                "refresh": refresh_token,
                "refreshTTL": expiration,
                "user": {
                    "email": user.email,
                    "name": user.name,
                    "roles": user.roles
                }
            }
        )
    )
}


//refresh token

pub fn refresh_token(refresh_token: &str, claims: &Claims,token: &str, singleton: &Singleton) -> Result<serde_json::value::Value, String> {
    let secret = singleton.config().lock().unwrap().jwt.token.clone();
    let token_ttl = singleton.config().lock().unwrap().jwt.token_ttl;
    let refresh_token_ttl = singleton.config().lock().unwrap().jwt.refresh_token_ttl;

    // Retrieve stored user info from Redis
    let user_data = match singleton.redis().get_refresh_token(refresh_token) {
        Ok(data) => data,
        Err(_) => return Err("Failed to retrieve refresh token. Token does not exist.".to_string()),
    };

    // Extract user ID and roles from the stored JSON data
    let parsed: serde_json::Value = serde_json::from_str(&user_data).map_err(|_| "Invalid refresh token data")?;
    let user_id = parsed["id"].as_str().ok_or("Invalid user ID")?.parse::<Uuid>().map_err(|_| "Invalid UUID format")?;
    
    
    match claims.sub.to_string().eq(&user_id.to_string()) {
        true => {},
        false => return Err("Refresh Token and JWT must belong to the same user".to_string()),
    }
    
    //Fetch user from db
    let roles: Vec<Role> =  vec![Role::Admin, Role::User, Role::Moderator]; // Mock role;

    // Generate a new JWT token
    let new_jwt = match generate_jwt(user_id, roles.clone(), &secret, token_ttl) {
        Ok(token) => token,
        Err(_) => return Err(String::from("Failed to generate new JWT token")),
    };

    // Generate a new refresh token
    let new_refresh_token = Uuid::new_v4();
    let expiration = Utc::now()
        .checked_add_signed(Duration::days(refresh_token_ttl))
        .expect("valid timestamp")
        .timestamp() as usize;
    
    singleton.redis().refresh_token(&new_refresh_token.to_string(), &user_id.to_string(), expiration as u64).unwrap();
    // Revoke the old refresh token
    singleton.redis().blacklist_jwt(token, claims.exp as u64).unwrap();
    singleton.redis().revoke_refresh_token(refresh_token).unwrap();

    Ok(serde_json::json!({
        "token": new_jwt,
        "refresh": new_refresh_token,
        "refreshTTL": expiration
    }))
}


pub fn logout_user(token: &str, exp: u64, refresh_token: &str, singleton: &Singleton) -> Result<serde_json::value::Value, String> {
    // Revoke the refresh token
    singleton.redis().revoke_refresh_token(refresh_token).unwrap();
    singleton.redis().blacklist_jwt(token, exp).unwrap();
    Ok(serde_json::json!({ "message": "Logged out successfully" }))
}
