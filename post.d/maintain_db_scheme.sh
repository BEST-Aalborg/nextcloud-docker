#!/usr/bin/env bash


echo "### Maintain DB Schemes ###"

echo "# [ occ db:add-missing-indices ]"
docker-compose exec -T --user www-data app php occ db:add-missing-indices

echo
echo "# [ occ db:add-missing-columns ]"
docker-compose exec -T --user www-data app php occ db:add-missing-columns

echo
echo " [ occ db:add-missing-primary-keys ]"
docker-compose exec -T --user www-data app php occ db:add-missing-primary-keys

echo
echo "# [ occ db:convert-filecache-bigint --no-interaction ]"
docker-compose exec -T --user www-data app php occ db:convert-filecache-bigint --no-interaction

echo
echo "# [ occ db:convert-mysql-charset --no-interaction ]"
docker-compose exec -T --user www-data app php occ db:convert-mysql-charset --no-interaction

echo
echo "# [ occ maintenance:mimetype:update-db ]"
docker-compose exec -T --user www-data app php occ maintenance:mimetype:update-db

if [ -z "${DOCKER_COMPOSE_FILE:-}" ]; then
	echo "ERROR: The variable  DOCKER_COMPOSE_FILE was not defined"
	exit 0
fi

