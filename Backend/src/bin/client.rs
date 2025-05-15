use reqwest::Client;
use std::fs::File;
use std::io::Read;
use std::path::Path;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let args: Vec<String> = std::env::args().collect();
    let file_path = args.get(1).map(|s| s.as_str()).unwrap_or("video.mp4");
    let token = args.get(2).map(|s| s.as_str()).unwrap_or("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJmNTY0Y2M3YS05YjUyLTQxYWUtYTUyYy0wNGIzOWQ4MjYyN2MiLCJleHAiOjE3NDY3MTM3MzQsInJvbGVzIjpbIkFkbWluIiwiVXNlciIsIk1vZGVyYXRvciJdfQ.axD3Tc27TgcC2krO-76Fs-iMvLq56n3QIF-_lw1rico");

    println!("File path: {}", file_path);
    println!("Token: {}", token);

    let file_size = std::fs::metadata(file_path)?.len();
    let file_name = Path::new(file_path).file_name().unwrap().to_str().unwrap();
    println!("File size: {}", file_size);


    let response = client
        .post("http://localhost/api/uploads")
        //.post("http://localhost:8080/uploads")
        .header("file_name", file_name)
        .header("file_length", file_size.to_string())
        .header("Authorization", &format!("Bearer {}", token))
        .send()
        .await?;


    let upload_url = response
        .headers()
        .get("Location")
        .ok_or("No Location header found")?
        .to_str()?;

    println!("Upload URL: {}", upload_url);



    // Step 2: Upload the file in chunks
    let mut file = File::open(file_path)?;
    let chunk_size = 1024 * 1024; // 1 MB
    let mut buffer = vec![0; chunk_size];
    let mut offset = 0;

    loop {
        let bytes_read = file.read(&mut buffer)?;
        if bytes_read == 0 {
            break; // End of file
        }

        let chunk = &buffer[..bytes_read];

        let response = client
            .patch(upload_url)
            .header("Content-Type", "application/offset+octet-stream")
            .header("Upload-Offset", offset.to_string())
            .header("Tus-Resumable", "1.0.0")
            .header("Authorization", &format!("Bearer {}", token))
            .body(chunk.to_vec())
            .send()
            .await?;

        offset += bytes_read as u64;
        println!("Uploaded {} bytes", offset);

        if !response.status().is_success() {
            return Err(format!("Upload failed: {}", response.status()).into());
        }
    }

    println!("Upload complete!");
    Ok(())
}                                                                                                                   