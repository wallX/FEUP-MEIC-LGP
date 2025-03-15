use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct UploadRequest {
    pub file_length: u64, // Mandatory field: size of the file in bytes
    pub file_name: String, // Mandatory field: name of the file
}