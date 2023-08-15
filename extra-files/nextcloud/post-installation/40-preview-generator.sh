#!/usr/bin/env bash

set -eu

php occ app:install previewgenerator | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'

# Source for the settings: https://rayagainstthemachine.net/linux%20administration/nextcloud-photos/
php occ config:app:set --value "60"      -- preview          jpeg_quality

php occ config:app:set --value="32 256"  -- previewgenerator squareSizes
php occ config:app:set --value="256 384" -- previewgenerator widthSizes
php occ config:app:set --value="256"     -- previewgenerator heightSizes


# The php code, loads the config content `config/config.php` adds 3 values
# and overwrites the `config/config.php` file with the changes.
php <<'zzzEndOfFilezzz'
<?php
$config_file_path = 'config/config.php';
include($config_file_path);

$CONFIG['preview_max_x'] = '2048';
$CONFIG['preview_max_y'] = '2048';
$CONFIG['jpeg_quality']  =   '60';

$new_config_file_content = '';
$new_config_file_content .= "<?php\n";
$new_config_file_content .= '$CONFIG = ';
$new_config_file_content .= var_export($CONFIG, true);
$new_config_file_content .= ";\n";

$config_file_obj = fopen($config_file_path, "w") or die("Unable to open file: $config_file_path");
fwrite($config_file_obj, $new_config_file_content);
fclose($config_file_obj);
?>
zzzEndOfFilezzz


