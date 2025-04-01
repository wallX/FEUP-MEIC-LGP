use serde::{Serialize, Deserialize};
use uuid::Uuid;
use crate::model::api::Role::Role;

#[derive(Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub hash: String,
    pub email: String,
    pub roles: Vec<Role>,
    pub is_active: bool,
}