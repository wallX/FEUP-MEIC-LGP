use reqwest::Client;
use std::fs::File;
use std::hash::Hash;
use std::io::Read;
use std::path::Path;
use crate::password_util::{hash_password, verify_password};

#[path = "../utils/password_util.rs"]
mod password_util;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    
   let hash = match hash_password("password".to_string().as_ref()){
        Ok(hash) => {
            println!("Hash: {}", hash);
            hash
        },
        Err(e) => {
            return Err("Couldn't hash password".to_string().into());
        }
    };

    println!("{}", verify_password("password".to_string().as_ref(), hash.as_ref()));
    
    
    Ok(())
    
    
   
   
}