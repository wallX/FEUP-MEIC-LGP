use std::str::FromStr;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, PartialEq)]
#[derive(Clone)]
pub enum Role {
    Admin,
    Moderator,
    Reporter,
    User,
}

impl FromStr for Role {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "admin" => Ok(Role::Admin),
            "moderator" => Ok(Role::Moderator),
            "reporter" => Ok(Role::Reporter),
            "user" => Ok(Role::User),
            _ => Err(format!("Invalid role: {}", s)),
        }
    }
}