-- Création du type ENUM pour le statut
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('active', 'suspended', 'pending');
    END IF;
END $$;

-- Table : users
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) NULL,
    email VARCHAR(191) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    -- Images de profil
    avatar_url_sm VARCHAR(512) NULL,
    avatar_url_md VARCHAR(512) NULL,
    avatar_url_lg VARCHAR(512) NULL,

    -- Crédits
    credits INT NOT NULL DEFAULT 0,

    -- Sécurité & Statuts
    status user_status NOT NULL DEFAULT 'active',
    suspension_reason TEXT NULL,
    registration_ip VARCHAR(45) NULL,
    last_login_ip VARCHAR(45) NULL,

    -- Profile
    age INT NULL,
    gender VARCHAR(20) NULL,
    bio TEXT NULL,

    -- Horodatage
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Table : admin_tokens
CREATE TABLE IF NOT EXISTS admin_tokens (
    token VARCHAR(255) PRIMARY KEY,
    user_id BIGINT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_admin_tokens_user
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table : global_settings
CREATE TABLE IF NOT EXISTS global_settings (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default credit price
INSERT INTO global_settings (key, value)
VALUES ('credit_price_dzd', '100')
ON CONFLICT (key) DO NOTHING;

-- Insert default kie multiplier
INSERT INTO global_settings (key, value)
VALUES ('kie_multiplier', '1')
ON CONFLICT (key) DO NOTHING;

-- Insert default SMTP settings
INSERT INTO global_settings (key, value)
VALUES ('smtp_host', '')
ON CONFLICT (key) DO NOTHING;

INSERT INTO global_settings (key, value)
VALUES ('smtp_port', '587')
ON CONFLICT (key) DO NOTHING;

INSERT INTO global_settings (key, value)
VALUES ('smtp_user', '')
ON CONFLICT (key) DO NOTHING;

INSERT INTO global_settings (key, value)
VALUES ('smtp_pass', '')
ON CONFLICT (key) DO NOTHING;

-- Création du type ENUM pour le statut de transaction
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_status') THEN
        CREATE TYPE transaction_status AS ENUM ('waiting', 'completed', 'canceled');
    END IF;
END $$;

-- Table : transactions
CREATE TABLE IF NOT EXISTS transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    chargily_checkout_id VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    credits_purchased INT NOT NULL,
    status transaction_status NOT NULL DEFAULT 'waiting',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transactions_user
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_checkout_id ON transactions(chargily_checkout_id);

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

-- Table : ai_model_configs
CREATE TABLE IF NOT EXISTS ai_model_configs (
    id VARCHAR(255) PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    logo_url VARCHAR(1024) DEFAULT '',
    type VARCHAR(100) DEFAULT 'unknown',
    name VARCHAR(255) DEFAULT '',
    family VARCHAR(255) DEFAULT '',
    endpoint_url TEXT DEFAULT '',
    api_config JSONB NULL,
    parameters JSONB NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
