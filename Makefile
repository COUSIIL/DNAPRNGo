.PHONY: help dev dev-build prod prod-build stop clean deploy

help:
	@echo "Available commands:"
	@echo "  make dev         - Start development environment"
	@echo "  make dev-build   - Start development environment and rebuild images"
	@echo "  make prod        - Start production environment"
	@echo "  make prod-build  - Start production environment and rebuild images"
	@echo "  make stop        - Stop development environment"
	@echo "  make clean       - Stop all environments and remove volumes/orphans"
	@echo "  make deploy      - Run deployment script"

dev:
	./scripts/start.sh

dev-build:
	docker compose up --build

prod:
	docker compose -f docker-compose.prod.yml up -d

prod-build:
	docker compose -f docker-compose.prod.yml up -d --build

stop:
	./scripts/stop.sh

clean:
	docker compose down -v --remove-orphans
	docker compose -f docker-compose.prod.yml down -v --remove-orphans

deploy:
	./scripts/deploy.sh
