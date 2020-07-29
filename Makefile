.PHONY: b dark docker down es install ps restart up update

b:
	@docker-compose up --build -d

dark:
	@helpers/dark.sh

docker:
	@helpers/docker.sh

down:
	@docker-compose down

es:
	@docker-compose exec server bash

install:
	@helpers/installer.sh

ps:
	@docker-compose ps

restart: down up
	@echo "Restarting finished."

up:
	@docker-compose up -d

update:
	@docker-compose pull && docker-compose up -d
