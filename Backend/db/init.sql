CREATE DATABASE kwik;

\c kwik;

CREATE TYPE role_enum AS ENUM (
    'Admin',
    'Moderator',
    'Reporter',
    'User'
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    password_hash TEXT NOT NULL,
    roles role_enum[] NOT NULL DEFAULT ARRAY['User']::role_enum[]
);

CREATE INDEX idx_users_email ON users(email);
