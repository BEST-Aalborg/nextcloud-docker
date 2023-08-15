#!/usr/bin/env bash


echo "### Maintain DB Schemes ###"

echo "# [ occ db:add-missing-indices ]"
php occ db:add-missing-indices

echo
echo "# [ occ db:add-missing-columns ]"
php occ db:add-missing-columns

echo
echo " [ occ db:add-missing-primary-keys ]"
php occ db:add-missing-primary-keys

echo
echo "# [ occ db:convert-filecache-bigint --no-interaction ]"
php occ db:convert-filecache-bigint --no-interaction

echo
echo "# [ occ db:convert-mysql-charset --no-interaction ]"
php occ db:convert-mysql-charset --no-interaction

echo
echo "# [ occ maintenance:mimetype:update-db ]"
php occ maintenance:mimetype:update-db

