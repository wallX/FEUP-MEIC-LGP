use redis::Commands;
use crate::utils::Singleton;

pub struct RedisClient {
    pub redis_url: String,
    pub client: redis::Client,
}

impl RedisClient {
    pub fn new(redis_url: String) -> Self {
        RedisClient{
            redis_url: redis_url.clone(),
            client: redis::Client::open(redis_url).expect("Invalid connection URL"),
        }
    }
}