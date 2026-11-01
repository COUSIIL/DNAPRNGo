// Package server wires middleware and routes into a Fiber application.
package server

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/helmet"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/fiber/v2/middleware/requestid"

	"go-backend/internal/config"
	"go-backend/internal/handler"
)

// New creates the Fiber application with all middleware and routes.
func New(cfg *config.Config, h *handler.Handler) *fiber.App {
	app := fiber.New(fiber.Config{
		AppName:       "go-backend",
		ReadTimeout:   10 * time.Second,
		WriteTimeout:  15 * time.Second,
		IdleTimeout:   60 * time.Second,
		BodyLimit:     4 * 1024 * 1024,
		ErrorHandler:  errorHandler,
		ProxyHeader:   fiber.HeaderXForwardedFor, // behind Nginx
		CaseSensitive: true,
	})

	app.Use(recover.New())
	app.Use(requestid.New())
	app.Use(logger.New(logger.Config{
		Format: "${time} ${locals:requestid} ${status} ${latency} ${method} ${path}\n",
	}))
	app.Use(helmet.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: cfg.CORSOrigins,
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET,POST,PUT,PATCH,DELETE,OPTIONS",
	}))
	app.Use(limiter.New(limiter.Config{
		Max:        120,
		Expiration: time.Minute,
		Next:       func(c *fiber.Ctx) bool { return c.Path() == "/health" },
	}))

	app.Get("/health", h.Health)

	// Demo route: never exposed in production (unauthenticated personal data).
	if !cfg.IsProduction() {
		app.Get("/users", h.ListUsers)
	}

	return app
}

// errorHandler returns every error as a JSON payload {"error": "..."}.
func errorHandler(c *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	msg := "internal server error"
	var fe *fiber.Error
	if errors.As(err, &fe) {
		code, msg = fe.Code, fe.Message
	}
	return c.Status(code).JSON(fiber.Map{"error": msg})
}

