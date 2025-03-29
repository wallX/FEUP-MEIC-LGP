use config::Config;
use once_cell::sync::Lazy;
use serde::{Deserialize, Deserializer};
use std::sync::Mutex;


#[derive(Debug, Deserialize)]
pub struct TusdConfig {
    pub protocol: String,
    pub internal_name: String,
    pub internal_port: String,

    pub external_name: String,
    pub external_port: Option<String>,
    pub external_endpoint: Option<String>,

    pub endpoint: String,
    #[serde(skip_deserializing)]  // Skip deserialization for this field
    pub url: String,

    #[serde(skip_deserializing)]  // Skip deserialization for this field
    pub internal_host: String,

    #[serde(skip_deserializing)]  // Skip deserialization for this field
    pub external_host: String,
}

impl TusdConfig {
    // Custom function to compute `url` and `external`
    fn compute_fields(&mut self) {
        self.url = format!(
            "{}://{}:{}/{}",
            self.protocol, self.internal_name, self.internal_port, self.endpoint
        );
        self.external_host = if self.external_port.is_some() && self.external_endpoint.is_some() {
            format!(
                "{}:{}/{}",
                self.external_name,
                self.external_port.as_ref().unwrap(),  // Borrow instead of move
                self.external_endpoint.as_ref().unwrap().trim_matches('/')
            )
        } else if self.external_port.is_some() {
            format!(
                "{}:{}",
                self.external_name,
                self.external_port.as_ref().unwrap()  // Borrow instead of move
            )
        } else if self.external_endpoint.is_some() {
            format!(
                "{}/{}",
                self.external_name,
                self.external_endpoint.as_ref().unwrap().trim_matches('/')  // Borrow instead of move
            )
        } else {
            self.external_name.clone()
        };
        self.internal_host = format!(
            "{}:{}",
            self.internal_name, self.internal_port
        );
    }
}


#[derive(Debug, Deserialize)]
pub struct AppConfig {
    #[serde(deserialize_with = "deserialize_tusd_config")]
    pub tusd: TusdConfig,
}

// Custom deserialization function for TusdConfig
fn deserialize_tusd_config<'de, D>(deserializer: D) -> Result<TusdConfig, D::Error> where
    D: Deserializer<'de> {
    // Deserialize the TusdConfig struct
    let mut tusd_config = TusdConfig::deserialize(deserializer)?;

    // Compute the `url` and `external` fields
    tusd_config.compute_fields();

    Ok(tusd_config)
}




static APP_CONFIG: Lazy<Mutex<AppConfig>> = Lazy::new(|| {
    Mutex::new(load_config().expect("Failed to load configuration"))
});

pub fn load_config() -> Result<AppConfig, config::ConfigError> {
    let settings = Config::builder()
        .add_source(config::File::with_name("config"))
        .build()?;

    settings.try_deserialize()
}

pub fn get_config() -> &'static Mutex<AppConfig> {
    &APP_CONFIG
}