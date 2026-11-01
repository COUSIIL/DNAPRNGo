// Package config loads and validates the application configuration
// from environment variables (12-factor).
package config

import (
	"fmt"
	"os"
	"strings"
)

// Config holds every runtime setting of the API.
type Config struct {
	Env         string // "development" | "production"
	Port        string
	CORSOrigins string
	JWTSecret   string

	PostgresHost     string
	PostgresPort     string
	PostgresUser     string
	PostgresPassword string
	PostgresDB       string

	RedisHost string
	RedisPort string
}

// IsProduction reports whether the API runs in production mode.
func (c *Config) IsProduction() bool { return c.Env == "production" }

// PostgresDSN builds the lib/pq connection string.
func (c *Config) PostgresDSN() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		c.PostgresHost, c.PostgresPort, c.PostgresUser, c.PostgresPassword, c.PostgresDB)
}

// RedisAddr returns the host:port address of Redis.
func (c *Config) RedisAddr() string { return c.RedisHost + ":" + c.RedisPort }

// Load reads the environment and returns a validated Config.
func Load() (*Config, error) {
	cfg := &Config{
		Env:         getEnv("APP_ENV", "development"),
		Port:        getEnv("API_PORT", "8080"),
		CORSOrigins: getEnv("CORS_ALLOW_ORIGINS", "http://localhost"),
		JWTSecret:   os.Getenv("JWT_SECRET"),

		PostgresHost:     getEnv("POSTGRES_HOST", "localhost"),
		PostgresPort:     getEnv("POSTGRES_PORT", "5432"),
		PostgresUser:     os.Getenv("POSTGRES_USER"),
		PostgresPassword: os.Getenv("POSTGRES_PASSWORD"),
		PostgresDB:       os.Getenv("POSTGRES_DB"),

		RedisHost: getEnv("REDIS_HOST", "localhost"),
		RedisPort: getEnv("REDIS_PORT", "6379"),
	}
	return cfg, cfg.validate()
}

func (c *Config) validate() error {
	var missing []string
	for _, kv := range [][2]string{
		{"POSTGRES_USER", c.PostgresUser},
		{"POSTGRES_PASSWORD", c.PostgresPassword},
		{"POSTGRES_DB", c.PostgresDB},
	} {
		if kv[1] == "" {
			missing = append(missing, kv[0])
		}
	}
	if c.IsProduction() && len(c.JWTSecret) < 32 {
		missing = append(missing, "JWT_SECRET (min 32 chars)")
	}
	if len(missing) > 0 {
		return fmt.Errorf("invalid configuration, check: %s", strings.Join(missing, ", "))
	}
	return nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

