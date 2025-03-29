use std::collections::HashMap;
use reqwest::{Client, Response};
use crate::model::api::uploads::NativeResponse;

pub struct TusClient<'a> {
    client: &'a Client,  // Explicit lifetime
    tusd_url: &'a String,
}

impl <'a> TusClient<'a> {
    pub fn new(client: &'a Client, tusd_url: &'a String) -> Self {
        Self { client, tusd_url }
    }

    pub async fn initiate_upload(&self, file_length: u64, metadata: String,internal_host: &String, external_host: &String ) -> Result<NativeResponse, String> {
       match self.client
            .post(self.tusd_url)
            .header("Upload-Length", file_length.to_string())
            .header("Tus-Resumable", "1.0.0")
            .header("Upload-Metadata", metadata)
            .send()
            .await {
           Ok(response) => Ok(NativeResponse::from_reqwest(&response, internal_host, external_host)),
           Err(_) => Err("Failed to send request to tusd".parse().unwrap()),
       }
    }

}

impl NativeResponse {
    pub fn from_reqwest(response: &Response, internal_host: &String, external_host: &String) -> Self {
        let mut headers = HashMap::new();

        for (key, value) in response.headers().iter() {
            let value_str = value.to_str().unwrap_or("").to_string();
            if key.as_str() == "location" {
                headers.insert(
                    "location".to_string(),
                    value_str.replace(internal_host, &external_host),
                );
            } else {
                headers.insert(key.to_string(), value_str);
            }
        }

        NativeResponse {
            status: response.status().as_u16(),
            headers,
        }
    }
}