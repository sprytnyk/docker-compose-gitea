.PHONY: b dark docker down es install ps restart uniptables up update

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

iptables:
	@helpers/iptables.sh

ps:
	@docker-compose ps

restart: down up
	@echo "Restarting finished."

ri:
	@helpers/ri.sh

uniptables:
	@helpers/uniptables.sh

up:
	@docker-compose up -d

update:
	@docker-compose pull && docker-compose up -d
