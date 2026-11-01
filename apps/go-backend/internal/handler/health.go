package handler

import (
	"context"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Health reports the state of the API and its dependencies.
// It answers 200 when everything is up and 503 otherwise, so it can be
// used by Docker healthchecks, load balancers and deployment scripts.
func (h *Handler) Health(c *fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	postgres, redisStatus := "up", "up"
	if err := h.DB.PingContext(ctx); err != nil {
		postgres = "down"
	}
	if err := h.Redis.Ping(ctx).Err(); err != nil {
		redisStatus = "down"
	}

	status, code := "ok", fiber.StatusOK
	if postgres == "down" || redisStatus == "down" {
		status, code = "degraded", fiber.StatusServiceUnavailable
	}

	return c.Status(code).JSON(fiber.Map{
		"status":   status,
		"postgres": postgres,
		"redis":    redisStatus,
	})
}

