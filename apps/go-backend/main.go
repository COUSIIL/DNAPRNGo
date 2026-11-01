package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var (
	db  *sql.DB
	rdb *redis.Client
	ctx = context.Background()
)

func initDB() {
	var err error
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_PORT"),
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_DB"),
	)

	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatalf("Error opening database connection: %v", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)

	err = db.Ping()
	if err != nil {
		log.Printf("Warning: Unable to ping database: %v", err)
	} else {
		log.Println("Connected to PostgreSQL successfully")
	}
}

func initRedis() {
	redisAddr := fmt.Sprintf("%s:%s", os.Getenv("REDIS_HOST"), os.Getenv("REDIS_PORT"))
	rdb = redis.NewClient(&redis.Options{
		Addr: redisAddr,
	})

	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		log.Printf("Warning: Unable to connect to Redis at %s: %v", redisAddr, err)
	} else {
		log.Println("Connected to Redis successfully")
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	// Initialize Connections
	initDB()
	initRedis()

	app := fiber.New()

	// Middleware
	app.Use(recover.New())
	app.Use(logger.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: getEnv("CORS_ALLOW_ORIGINS", "http://localhost"),
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
	}))

	// Health Endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		dbStatus := "down"
		if err := db.Ping(); err == nil {
			dbStatus = "up"
		}

		redisStatus := "down"
		if _, err := rdb.Ping(ctx).Result(); err == nil {
			redisStatus = "up"
		}

		return c.JSON(fiber.Map{
			"status": "ok",
			"postgres": dbStatus,
			"redis": redisStatus,
		})
	})

	// Example Route using DB (Verifying connection and table from init.sql)
	app.Get("/users", func(c *fiber.Ctx) error {
		rows, err := db.QueryContext(c.Context(), "SELECT id, name, email FROM users")
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"error": "Failed to query database"})
		}
		defer rows.Close()

		users := []fiber.Map{}
		for rows.Next() {
			var id int
			var name, email string
			if err := rows.Scan(&id, &name, &email); err != nil {
				return c.Status(500).JSON(fiber.Map{"error": "Failed to scan row"})
			}
			users = append(users, fiber.Map{"id": id, "name": name, "email": email})
		}

		if err := rows.Err(); err != nil {
			return c.Status(500).JSON(fiber.Map{"error": "Failed to read rows"})
		}

		return c.JSON(users)
	})

	port := getEnv("API_PORT", "8080")

	// Graceful shutdown on SIGINT/SIGTERM
	go func() {
		quit := make(chan os.Signal, 1)
		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
		<-quit
		log.Println("Shutting down...")
		_ = app.ShutdownWithTimeout(10 * time.Second)
	}()

	log.Printf("Starting server on port %s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
	_ = db.Close()
	_ = rdb.Close()
}
