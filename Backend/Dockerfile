# Use the official Rust image as the base
FROM rust:latest

# Set the working directory inside the container
WORKDIR /app

# Install any additional dependencies if needed
# RUN apt-get update && apt-get install -y some-dependency

RUN cargo install cargo-watch

# Default command: Run `cargo run` when the container starts
CMD ["cargo", "watch", "-x", "run" ]