-- Migration 12: Add endpoint_url, api_config (JSONB), and parameters (JSONB) to ai_model_configs
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

ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS type VARCHAR(100) DEFAULT 'unknown';
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS name VARCHAR(255) DEFAULT '';
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS family VARCHAR(255) DEFAULT '';
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS endpoint_url TEXT DEFAULT '';
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS api_config JSONB NULL;
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS parameters JSONB NULL;
ALTER TABLE ai_model_configs ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

