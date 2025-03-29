use std::collections::HashMap;

pub struct UploadRequest {
    pub file_name: String,
    pub file_length: u64,
}
pub struct NativeResponse {
    pub status: u16,
    pub headers: HashMap<String, String>,
}