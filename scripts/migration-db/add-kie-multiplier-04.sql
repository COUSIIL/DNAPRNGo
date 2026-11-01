INSERT INTO global_settings (key, value)
VALUES ('kie_multiplier', '1')
ON CONFLICT (key) DO NOTHING;
