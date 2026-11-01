-- Table : user_storage
CREATE TABLE IF NOT EXISTS user_storage (
    user_id BIGINT PRIMARY KEY,
    total_bytes_used BIGINT NOT NULL DEFAULT 0 CHECK (total_bytes_used >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_storage_user
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table : files
CREATE TABLE IF NOT EXISTS files (
    id UUID PRIMARY KEY,
    user_id BIGINT NOT NULL,
    file_key VARCHAR(1024) UNIQUE NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    media_type VARCHAR(50) NOT NULL,
    source VARCHAR(50) NOT NULL,
    size_bytes BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_files_user
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_files_user_id ON files(user_id);
