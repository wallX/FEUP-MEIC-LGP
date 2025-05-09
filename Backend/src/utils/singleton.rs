use crate::config::config;
use crate::config::config::AppConfig;
use crate::interface::redis::redis::RedisClient;
use crate::services::pipeline_queue::PipelineQueue;
use redis::Commands;
use reqwest::Client;
use std::sync::{Arc, Mutex, OnceLock};
// ... other imports

pub struct Singleton {
    config : OnceLock<Arc<Mutex<config::AppConfig>>>,
    client: OnceLock<Client>,
    queue: OnceLock<PipelineQueue>,
    redis: OnceLock<RedisClient>,
    postgres: OnceLock<sqlx::PgPool>,
}

impl Singleton {
    pub fn new_empty() -> Result<Self, &'static str> {

       let ret = Ok(Self {
            config: OnceLock::new(),
            client: OnceLock::new(),
            queue: OnceLock::new(),
            redis: OnceLock::new(),
            postgres: OnceLock::new(),
        });

       ret

    }

    pub fn init_config(&self, config: AppConfig) -> Result<(), Arc<Mutex<AppConfig>>> {
        self.config.set(Arc::new(Mutex::new(config)))
    }

    pub fn init_client(&self, client: Client) -> Result<(), Client> {
        self.client.set(client)
    }

    pub fn init_queue(&self, queue: PipelineQueue) -> Result<(), PipelineQueue> {
        self.queue.set(queue)
    }

    pub fn init_redis(&self, redis: RedisClient) -> Result<(), RedisClient> {
        self.redis.set(redis)
    }

    pub fn init_postgres(&self, postgres: sqlx::PgPool) -> Result<(), sqlx::PgPool> {
        self.postgres.set(postgres)
    }

    pub fn config(&self) -> &Mutex<config::AppConfig> {
        self.config.get().expect("Config not initialized")
    }

    pub fn client(&self) -> &Client {
        self.client.get().expect("Client not initialized")
    }

    pub fn queue(&self) -> &PipelineQueue {
        self.queue.get().expect("Queue not initialized")
    }

    pub fn redis(&self) -> &RedisClient {
        self.redis.get().expect("Redis not initialized")
    }

    pub fn postgres(&self) -> &sqlx::PgPool {
        self.postgres.get().expect("Postgres not initialized")
    }

}