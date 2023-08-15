#!/usr/bin/env bash

set -eu

php occ app:install fulltextsearch               | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'
php occ app:install files_fulltextsearch         | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'
php occ app:install fulltextsearch_elasticsearch | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'


php occ files_fulltextsearch:configure         '{"files_local":"1","files_group_folders":"1","files_pdf":"1","files_office":"1","files_image":"1","files_audio":"1"}'

php occ fulltextsearch:configure               '{"search_platform":"OCA\\FullTextSearch_Elasticsearch\\Platform\\ElasticSearchPlatform"}'

php occ fulltextsearch_elasticsearch:configure '{"elastic_host":"http://elasticsearch:9200/","elastic_index":"nextcloud_index"}'

php occ fulltextsearch:reset
php occ fulltextsearch:index --quiet


