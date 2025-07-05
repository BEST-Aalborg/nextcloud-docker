#!/usr/bin/env bash


echo "### Maintain minetypes migration ###"

echo "# [ occ maintenance:repair --include-expensive ]"
php occ maintenance:repair --include-expensive


