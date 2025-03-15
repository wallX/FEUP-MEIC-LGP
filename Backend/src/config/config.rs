use config::Config;
use once_cell::sync::Lazy;
use serde::Deserialize;
use std::sync::Mutex;


#[derive(Debug, Deserialize)]
pub struct TusdConfig {
    pub url: String,
    pub upload_path: String,
}

#[derive(Debug, Deserialize)]
pub struct AppConfig {
    pub tusd: TusdConfig,
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