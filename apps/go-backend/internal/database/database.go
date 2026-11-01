// Package database creates the PostgreSQL and Redis clients.
package database

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"

	"go-backend/internal/config"
)

const (
	connectTimeout = 5 * time.Second
	maxAttempts    = 10
	retryDelay     = 2 * time.Second
)

// NewPostgres opens a connection pool and waits until the database answers.
func NewPostgres(ctx context.Context, cfg *config.Config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.PostgresDSN())
	if err != nil {
		return nil, fmt.Errorf("open postgres: %w", err)
	}
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)

	var lastErr error
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		pingCtx, cancel := context.WithTimeout(ctx, connectTimeout)
		lastErr = db.PingContext(pingCtx)
		cancel()
		if lastErr == nil {
			return db, nil
		}
		select {
		case <-ctx.Done():
			_ = db.Close()
			return nil, ctx.Err()
		case <-time.After(retryDelay):
		}
	}
	_ = db.Close()
	return nil, fmt.Errorf("ping postgres after %d attempts: %w", maxAttempts, lastErr)
}

// NewRedis creates a Redis client and checks the connection.
func NewRedis(ctx context.Context, cfg *config.Config) (*redis.Client, error) {
	client := redis.NewClient(&redis.Options{Addr: cfg.RedisAddr()})

	pingCtx, cancel := context.WithTimeout(ctx, connectTimeout)
	defer cancel()
	if err := client.Ping(pingCtx).Err(); err != nil {
		_ = client.Close()
		return nil, fmt.Errorf("ping redis at %s: %w", cfg.RedisAddr(), err)
	}
	return client, nil
}

