#!/usr/bin/env bash

set -eu

php occ app:disable firstrunwizard
php occ app:disable dashboard
php occ app:disable circles
php occ app:disable federation


