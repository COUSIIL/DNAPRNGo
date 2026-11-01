.PHONY: help dev dev-build stop logs ps clean prod prod-build deploy lint-compose

help:
	@echo "Development"
	@echo "  make dev           - Init DB, start all services and follow logs"
	@echo "  make dev-build     - Start the dev stack and rebuild images"
	@echo "  make stop          - Stop the dev stack"
	@echo "  make logs          - Follow logs of every service"
	@echo "  make ps            - Show service status"
	@echo "  make clean         - Remove containers, volumes and unused Docker data"
	@echo "Production"
	@echo "  make prod          - Start the production stack"
	@echo "  make prod-build    - Start the production stack and rebuild images"
	@echo "  make deploy        - Deploy to the VPS over SSH (see scripts/deploy.sh)"
	@echo "Quality"
	@echo "  make lint-compose  - Validate both compose files"

dev:
	./scripts/start.sh

dev-build:
	docker compose up --build

stop:
	./scripts/stop.sh

logs:
	docker compose logs -f

ps:
	docker compose ps

clean:
	./scripts/clean-docker.sh

prod:
	docker compose -f docker-compose.prod.yml up -d

prod-build:
	docker compose -f docker-compose.prod.yml up -d --build

deploy:
	./scripts/deploy.sh

lint-compose:
	docker compose config -q
	docker compose -f docker-compose.prod.yml config -q
