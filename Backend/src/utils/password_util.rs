use argon2::password_hash::rand_core::OsRng;
use argon2::password_hash::SaltString;
use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};

/// Generates a password hash and a random salt.
///
/// Returns a tuple `(hash, salt)`.
pub fn hash_password(password: &str) -> Result<String, String> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let password_hash = match argon2.hash_password(password.as_ref(), &salt) {
        Ok(hash) => hash.to_string(),  // Store the full encoded hash
        Err(_) => return Err("Couldn't hash password".to_string()),
    };

    Ok(password_hash,)
}

/// Verifies if a password matches the stored hash and salt.
pub fn verify_password(password: &str, hash: &str) -> bool {
    let argon2 = Argon2::default();
    let parsed_hash = match PasswordHash::new(&hash){
        Ok(hash) => hash,
        Err(_) => return false,
    };
    Argon2::default().verify_password(password.as_bytes(), &parsed_hash).is_ok()
}