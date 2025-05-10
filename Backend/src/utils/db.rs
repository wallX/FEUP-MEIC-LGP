use sqlx::postgres::PgPoolOptions;
use std::env;
use dotenv::dotenv;

// #[tokio::main]
pub async fn connect() -> sqlx::Result<sqlx::PgPool, sqlx::Error> {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    PgPoolOptions::new()
        .max_connections(5)
        .test_before_acquire(true)
        .connect(&database_url)
        .await
}
