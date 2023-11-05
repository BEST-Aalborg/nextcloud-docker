#!/usr/bin/env bash

set -eu

exit 0

php occ app:install recognize | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'


php occ recognize:download-models


