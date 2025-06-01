.PHONY: server frontend dev

server:
	cd news_show_backend && node server.js

frontend:
	cd news_show && npm run dev

dev:
	@echo "Starting frontend in Docker and backend normally..."
	@docker-compose up frontend -d && \
	cd news_show_backend && node server.js & \
	wait

stop:
	@echo "Stopping Docker containers..."
	@docker-compose down
