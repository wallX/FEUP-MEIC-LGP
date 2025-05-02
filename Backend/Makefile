# Makefile

# Default target (can be run with just `make`)
run:
	@echo "Starting app services..."
	docker-compose -f docker-compose.yaml up -d

# Target to run both services
runAll:
	@echo "Starting app and monitoring services..."
	docker-compose -f docker-compose.yaml -f docker-compose.monitoring.yaml up -d

# Stop services
stop:
	@echo "Stopping services..."
	docker-compose stop