use crate::model::api::Role::Role;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub hash: String,
    pub email: String,
    pub roles: Vec<Role>,
    pub is_active: bool,
}