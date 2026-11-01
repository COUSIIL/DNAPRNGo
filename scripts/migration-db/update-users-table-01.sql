-- 1. Création du type ENUM s'il n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('active', 'suspended', 'pending');
    END IF;
END $$;

-- 2. Refonte de la table users
ALTER TABLE users
    RENAME COLUMN name TO first_name;

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS last_name VARCHAR(100) NOT NULL DEFAULT '',
    ADD COLUMN IF NOT EXISTS nickname VARCHAR(50) NULL,
    ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255) NOT NULL DEFAULT '',
    ADD COLUMN IF NOT EXISTS avatar_url_sm VARCHAR(512) NULL,
    ADD COLUMN IF NOT EXISTS avatar_url_md VARCHAR(512) NULL,
    ADD COLUMN IF NOT EXISTS avatar_url_lg VARCHAR(512) NULL,
    ADD COLUMN IF NOT EXISTS credits INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS status user_status NOT NULL DEFAULT 'active',
    ADD COLUMN IF NOT EXISTS suspension_reason TEXT NULL,
    ADD COLUMN IF NOT EXISTS registration_ip VARCHAR(45) NULL,
    ADD COLUMN IF NOT EXISTS last_login_ip VARCHAR(45) NULL,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
