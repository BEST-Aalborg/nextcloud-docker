#!/usr/bin/env bash

set -eu

internal_only_office_endpoint="http://${DOMAIN_ONLYOFFICE}/"

if [[ -n "${DOMAIN_ONLYOFFICE}" ]]; then
    php occ app:install onlyoffice | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'

    php occ config:app:set --value "https://${DOMAIN_ONLYOFFICE}/" -- onlyoffice DocumentServerUrl
    php occ config:app:set --value "${internal_only_office_endpoint}"  -- onlyoffice DocumentServerInternalUrl
    php occ config:app:set --value "http://${DOMAIN_NEXTCLOUD}/"   -- onlyoffice StorageUrl
    php occ config:app:set --value "false"                         -- onlyoffice sameTab
    php occ config:app:set --value ""                              -- onlyoffice settings_error

else
    echo 'Did not install onlyoffice - The environment DOMAIN_ONLYOFFICE was not configured'
fi


