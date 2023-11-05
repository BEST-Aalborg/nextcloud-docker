#!/usr/bin/env bash

set -eu

exit 0

php occ app:install facerecognition | grep -E '^[^ ]+ (already|([0-9]+\.?)+) installed$'


sed -e "s|%_API_KEY_%|$(tr -d '\n' <<<${FACE_RECOGNITION_API_KEY} | base64)|" <<'zzzEndOfFilezzz' | php
<?php
$config_file_path = 'config/config.php';
include($config_file_path);

$CONFIG['simpleSignUpLink.shown'] = false;
$CONFIG['default_locale']         = 'da_DK';
$CONFIG['facerecognition.external_model_url']     = 'http://face-recognition-external-model:5000';
$CONFIG['facerecognition.external_model_api_key'] = '%_API_KEY_%';


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

php occ face:setup --memory=1G
php occ face:setup --model=1
php occ face:setup --model=3
php occ face:setup --model=4


