// Package handler contains the HTTP handlers of the API.
package handler

import (
	"database/sql"

	"github.com/redis/go-redis/v9"
)

// Handler groups the dependencies shared by every route.
type Handler struct {
	DB    *sql.DB
	Redis *redis.Client
}

// New builds a Handler.
func New(db *sql.DB, rdb *redis.Client) *Handler {
	return &Handler{DB: db, Redis: rdb}
}

