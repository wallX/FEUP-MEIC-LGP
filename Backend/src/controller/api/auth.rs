use crate::interface::api::auth::LoginRequest;
use crate::model::api::jwt::{generate_jwt, validate_jwt, Claims};
use crate::model::api::user::User;
use crate::model::api::Role::Role;
use crate::utils::password_util::{hash_password, verify_password};
use crate::utils::Singleton;
use chrono::{Duration, Utc};
use jsonwebtoken::errors::ErrorKind;
use uuid::Uuid;

pub fn extract_jwt_controller (auth_str: &str, singleton: &Singleton) -> Result<(String,Claims), String> {
    let secret = singleton.config().lock().unwrap().jwt.token.clone();
    if auth_str.starts_with("Bearer ") {
        let token = &auth_str[7..];
        match singleton.redis().check_jwt(token) {
            Ok(false) => return Err("JWT is blacklisted".to_string()),
            Ok(_) => {},
            Err(_) => return Err("Failed to check JWT blacklist".to_string()),
        };
         return match validate_jwt(token, &secret) {
            Ok(claims) => Ok((token.parse().unwrap(), claims)),
            Err(err) => match *err.kind() {
                ErrorKind::ExpiredSignature => Err(String::from("JWT expired")),
                _ => Err(String::from("Invalid JWT")),
            },
        };
    }
    Err(String::from("Token Error Controller"))
}


pub fn validate_user_login(email: String, password: String, singleton: &Singleton) -> Result<User, String> {
    //fetch user from db but mock user for testing
    let mock_user = User {
        id: Uuid::new_v4(),
        email: "test@example.com".to_string(),
        hash: hash_password(&"password123".to_string())?, // Normally, use a hashed password!
        roles: vec![Role::Admin], // Mock role
        is_active: true,
    };
    
    // Password hasher 

    if email == mock_user.email && verify_password(password.as_ref(), mock_user.hash.as_ref()) {
        return Ok(mock_user);
    } 
    Err(String::from("Invalid email or password"))
}

pub fn generate_tokens(login: &LoginRequest, singleton: &Singleton) -> Result<serde_json::value::Value, String> {
    
    let user = match validate_user_login(login.email.clone(), login.password.clone(), singleton) {
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
    Ok(serde_json::json!({ "token": jwt, "refresh": refresh_token, "refreshTTL": expiration }))
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
    let roles: Vec<Role> = vec![Role::Admin];

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
