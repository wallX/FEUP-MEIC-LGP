use reqwest::Client;

pub struct Singleton {
    pub client: Client,
}