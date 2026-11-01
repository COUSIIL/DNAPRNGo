package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go-backend/internal/config"
	"go-backend/internal/database"
	"go-backend/internal/handler"
	"go-backend/internal/server"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	db, err := database.NewPostgres(ctx, cfg)
	if err != nil {
		log.Fatalf("database: %v", err)
	}
	defer db.Close()
	log.Println("Connected to PostgreSQL")

	rdb, err := database.NewRedis(ctx, cfg)
	if err != nil {
		log.Fatalf("redis: %v", err)
	}
	defer rdb.Close()
	log.Println("Connected to Redis")

	app := server.New(cfg, handler.New(db, rdb))

	// Graceful shutdown on SIGINT/SIGTERM
	go func() {
		<-ctx.Done()
		log.Println("Shutting down...")
		if err := app.ShutdownWithTimeout(10 * time.Second); err != nil {
			log.Printf("shutdown: %v", err)
		}
	}()

	log.Printf("Starting server on :%s (env=%s)", cfg.Port, cfg.Env)
	if err := app.Listen(":" + cfg.Port); err != nil {
		log.Printf("server stopped: %v", err)
		os.Exit(1)
	}
}
