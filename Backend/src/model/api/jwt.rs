use crate::model::api::Role::Role;
use chrono::{Duration, Utc};
use jsonwebtoken::{DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: Uuid,
    pub exp: usize,
    pub roles: Vec<Role>,  // Add roles field
}

pub fn generate_jwt(user_id: Uuid, roles: Vec<Role>, secret: &str, exp: i64) -> Result<String, jsonwebtoken::errors::Error> {
    let expiration = Utc::now()
        .checked_add_signed(Duration::minutes(exp))
        .expect("valid timestamp")
        .timestamp() as usize;

    let claims = Claims { sub: user_id, exp: expiration, roles };

    jsonwebtoken::encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_ref()),
    )
}

pub fn validate_jwt(token: &str, secret: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
    let token_data = jsonwebtoken::decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_ref()),
        &Validation::default(),
    )?;
    Ok(token_data.claims)
}