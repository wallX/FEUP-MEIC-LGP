use crate::model::api::Role::Role;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

// #[derive(Serialize, Deserialize)]
// pub struct User {
//     pub id: Uuid,
//     pub hash: String,
//     pub email: String,
//     pub roles: Vec<Role>,
//     pub is_active: bool,
// }

#[derive(sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    pub name: String,
    pub password_hash: String,
    pub roles: Vec<Role>,
}

pub async fn create_user(pool: &sqlx::PgPool, email: &str, name: &str, password_hash:&str) -> Result<(), sqlx::Error> {
    sqlx::query("INSERT INTO users (email, name, password_hash) VALUES ($1, $2, $3)")
        .bind(email)
        .bind(name)
        .bind(password_hash)
        .execute(pool)
        .await?;
    Ok(())
}

pub async fn get_user_by_email(pool: &sqlx::PgPool, email: &str) -> Result<User, sqlx::Error> {
    let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE email = $1")
        .bind(email)
        .fetch_one(pool)
        .await?;
    Ok(user)
}
