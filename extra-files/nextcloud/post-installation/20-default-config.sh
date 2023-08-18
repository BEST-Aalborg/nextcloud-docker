#!/usr/bin/env bash

set -eu

# The php code, loads the config content `config/config.php` adds 3 values
# and overwrites the `config/config.php` file with the changes.
php <<'zzzEndOfFilezzz'
<?php
$config_file_path = 'config/config.php';
include($config_file_path);

$CONFIG['simpleSignUpLink.shown'] = false;
$CONFIG['default_locale']         = 'da_DK';

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


