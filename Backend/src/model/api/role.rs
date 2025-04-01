use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, PartialEq)]
#[derive(Clone)]
pub enum Role {
    Admin,
    Moderator,
    Reporter,
    User,
}