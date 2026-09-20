CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO users (name, email) VALUES
    ('Alice Dupont', 'alice@exemple.com'),
    ('Bob Martin', 'bob@exemple.com')
ON CONFLICT (email) DO NOTHING;
