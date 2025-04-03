use redis::{Commands, RedisResult};

pub struct RedisClient {
    pub client: redis::Client,
}

impl RedisClient {
    pub fn new(redis_url: String) -> Self {
        RedisClient{
            client: redis::Client::open(redis_url).expect("Invalid connection URL"),
        }
    }

    pub async fn send_to_work_queue(&self, queue_name: &str, value: &str) -> RedisResult<()> {
        let mut con =self.client.get_connection()?;
        // Delete the key if it exists and isn't a list
        //let _: () = redis::cmd("DEL").arg(queue_name).query(&mut con)?;
        // Now LPUSH will work
        let t: usize = con.lpush(queue_name, value)?;
        let _: i32 = redis::cmd("INCR")
            .arg(format!("pending:{}", value))
            .query(&mut con)?;
        //println!("Pushed {} to queue {}. Queue length: {}", value, queue_name, t);
        Ok(())
    }

    pub async fn initiate_queue(&self, file_name: &str) -> RedisResult<()> {
        // Check if the file already exists in the queue
        let mut con = self.client.get_connection()?;
        let _: () = con.set_nx(format!("pending:{}", file_name), 0)?;
        Ok(())
    }

    pub async fn add_work_to_queues(&self, file_name: &str, queues: &[&str], ) -> RedisResult<()> {
        // Convert queues to comma-separated string
        let queues_str = queues.join(",");

        // Get async connection
        let mut con = self.client.get_connection()?;

        // Add to stream with metadata
        let _: String = con.xadd(
            "work_stream",  // Stream key
            "*",            // Auto-generate message ID
            &[
                ("file", file_name),
                ("queues", &queues_str),
                ("status", "pending"),
            ]
        )?;
        Ok(())
    }

    pub async fn listen_for_completion(&self, file_name:  &str) -> RedisResult<()> {
        let mut con = self.client.get_connection()?;
        let mut pubsub = con.as_pubsub();
        println!("Waiting for completion: {}", file_name);
        pubsub.subscribe(format!("completed:{}", file_name))?;

        let msg = pubsub.get_message()?;
        let payload : String = msg.get_payload()?;

        let mut con = self.client.get_connection()?;
        let _: () = con.del(format!("pending:{}", file_name))?;

        println!("channel '{}': {}", msg.get_channel_name(), payload);
        Ok(())
    }
    
    pub fn get_refresh_token(&self, refresh_token: &str,) -> RedisResult<String> {
        let mut con = self.client.get_connection()?;
        let user_id: String = con.get(format!("refresh_token:{}", refresh_token))?;
        Ok(user_id)
    }
    
    pub fn refresh_token(&self, refresh_token: &str, id: &str, expiry: u64) -> RedisResult<String> {
        let mut con = self.client.get_connection()?;
        let user_data = serde_json::json!({
        "id": id
        }).to_string();

        // Store the JSON with expiry
        let _: () = con.set_ex(format!("refresh_token:{}",refresh_token), user_data, expiry)?;
        
        Ok(refresh_token.to_string())
    }

    pub fn revoke_refresh_token(&self, refresh_token: &str) -> RedisResult<()> {
        let mut conn = self.client.get_connection()?;
        //let _: () = con.set_nx(format!("pending:{}", file_name), 0)?;
        let _: () = conn.del(format!("refresh_token:{}", refresh_token))?;
        Ok(())
    }
    
    pub fn blacklist_jwt(&self, jwt: &str, exp: u64) -> RedisResult<()> {
        let mut con = self.client.get_connection()?;
        let _: () = con.set_ex(format!("blacklist:{}", jwt), "blacklisted", exp)?;
        Ok(())
    }

    pub fn check_jwt(&self, jwt: &str) -> RedisResult<bool> {
        let mut con = self.client.get_connection()?;
        let result: Option<String> = con.get(format!("blacklist:{}", jwt))?;
        Ok(result.is_none()) 
    }
    



}