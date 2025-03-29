use serde_json::Value;
use std::path::Path;
use base64::{engine::general_purpose, Engine as _};
use crate::utils::Singleton;
use crate::config::config::get_config;
use crate::interface::api::tus_client::TusClient;
use crate::model::api::uploads::{NativeResponse, UploadRequest};

pub async fn initiate_upload_logic(req: UploadRequest, singleton: &Singleton) -> Result<NativeResponse, String> {
    let config = &get_config().lock().unwrap();

    let file_name = req.file_name.clone();
    let file_length = req.file_length.clone();

    if file_length < 1 {
        return Err(String::from("File length must be > 0"));
    }

    let file_extension = Path::new(&file_name)
        .extension()
        .unwrap()
        .to_str()
        .unwrap();
    let user = "alex";

    let metadata = format!(
        "filename {},extension {},username {}",
        general_purpose::STANDARD.encode(file_name.clone()),
        general_purpose::STANDARD.encode(file_extension),
        general_purpose::STANDARD.encode(user)
    );

    TusClient::new(&singleton.client, &config.tusd.url).initiate_upload(file_length, metadata, &config.tusd.internal_host, &config.tusd.external_host).await

}

pub async fn upload_ready_hook_logic( body: Value, singleton: &Singleton)
    -> Value {
    let json_data = body;

    let id = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("ID"))
        .and_then(|id| id.as_str())
        .unwrap_or("Unknown ID");

    let filename = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("MetaData"))
        .and_then(|md| md.get("filename"))
        .and_then(|fnm| fnm.as_str())
        .unwrap_or("Unknown filename");

    let username = json_data.get("Event")
        .and_then(|e| e.get("Upload"))
        .and_then(|u| u.get("MetaData"))
        .and_then(|md| md.get("username"))
        .and_then(|usr| usr.as_str())
        .unwrap_or("Unknown username");

    singleton.queue.add_file(id.to_string());

    serde_json::json!({
        "ID": id,
        "filename": filename,
        "username": username
    })
}