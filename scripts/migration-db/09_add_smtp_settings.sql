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
