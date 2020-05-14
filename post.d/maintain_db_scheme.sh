#!/usr/bin/env bash


echo "### Maintain DB Schemes ###"

<<<<<<< HEAD
docker-compose exec -T --user www-data app php occ db:add-missing-indices
docker-compose exec -T --user www-data app php occ db:add-missing-columns
docker-compose exec -T --user www-data app php occ db:add-missing-primary-keys
docker-compose exec -T --user www-data app php occ db:convert-filecache-bigint --no-interaction
docker-compose exec -T --user www-data app php occ db:convert-mysql-charset --no-interaction
#docker-compose exec -T --user www-data app php occ db:convert-type --no-interaction
docker-compose exec -T --user www-data app php occ maintenance:mimetype:update-db

=======
if [ -z "${DOCKER_COMPOSE_FILE:-}" ]; then
	echo "ERROR: The variable  DOCKER_COMPOSE_FILE was not defined"
	exit 0
fi

docker-compose -f "${DOCKER_COMPOSE_FILE}" exec -T --user www-data app php occ db:add-missing-indices
>>>>>>> 432a29c (Expost DOCKER_COMPOSE_FILE in start_and_watch.sh and added a post script for DB Schemes)


