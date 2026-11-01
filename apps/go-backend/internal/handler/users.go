package handler

import (
	"context"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

// User is the public representation of a user row.
type User struct {
	ID    int64  `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

// ListUsers is a demo route that verifies the database wiring.
// It is only registered outside production (see server.New) because it
// exposes personal data without authentication.
func (h *Handler) ListUsers(c *fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := h.DB.QueryContext(ctx,
		`SELECT id, TRIM(first_name || ' ' || last_name), email
		   FROM users ORDER BY id LIMIT 100`)
	if err != nil {
		log.Printf("list users: query: %v", err)
		return fiber.NewError(fiber.StatusInternalServerError, "failed to query database")
	}
	defer rows.Close()

	users := make([]User, 0)
	for rows.Next() {
		var u User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email); err != nil {
			log.Printf("list users: scan: %v", err)
			return fiber.NewError(fiber.StatusInternalServerError, "failed to read data")
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		log.Printf("list users: rows: %v", err)
		return fiber.NewError(fiber.StatusInternalServerError, "failed to read data")
	}

	return c.JSON(users)
}

