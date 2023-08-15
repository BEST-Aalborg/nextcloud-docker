#!/usr/bin/env bash

set -eu

# Check if Nextcloud is installed, if not, then don't continue
if php occ 2>&1 | grep --quiet '^Nextcloud is not installed'; then
    exit 0
fi


echo "### Update all the in-app in Nextcloud ###"
php occ app:update --all


