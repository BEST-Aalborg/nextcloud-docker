#!/usr/bin/env bash


echo "### Maintain DB Schemes ###"

docker-compose exec -T --user www-data app php occ db:add-missing-indices
docker-compose exec -T --user www-data app php occ db:add-missing-columns
docker-compose exec -T --user www-data app php occ db:add-missing-primary-keys
docker-compose exec -T --user www-data app php occ db:convert-filecache-bigint --no-interaction
docker-compose exec -T --user www-data app php occ db:convert-mysql-charset --no-interaction
#docker-compose exec -T --user www-data app php occ db:convert-type --no-interaction
docker-compose exec -T --user www-data app php occ maintenance:mimetype:update-db



