#!/usr/bin/env bash

### Why is this needed? ###
# Because OnlyOffice is being very annoring :(
#
# OnlyOffice removed the function to edit document in the web-browser on mobile platforms from there DocumentServer Community Edition
# Source: https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360
#
# There exists a fix there is easy to implement and that is what this script does.
# The fix is from the 23/03/2020 and I (Dennis) don't for how long it will work,
# but if we no longer can edit document on our mobile devices in the web-browser when it probably stopped working
# https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360/46
#
# DocumentServer - https://github.com/ONLYOFFICE/DocumentServer.

echo "### Applying the patch to OnlyOffice ###"

if [ -z "${DOCKER_COMPOSE_FILE:-}" ]; then
	echo "ERROR: The variable  DOCKER_COMPOSE_FILE was not defined"
	exit 0
fi

### Applying the patch ###
# by replace
# isSupportEditFeature:function(){return!1}
# with
# isSupportEditFeature:function(){return 1}
<<<<<<<< HEAD:post.d/patch_onlyoffice_to_enabled_editing_mode_on_mobile.sh.disable
cat <<'zEOFz' | docker-compose exec -T onlyoffice bash 
========
cat <<'zEOFz' | docker-compose -f "${DOCKER_COMPOSE_FILE}" exec -T onlyoffice bash 
>>>>>>>> 432a29c (Expost DOCKER_COMPOSE_FILE in start_and_watch.sh and added a post script for DB Schemes):post.d/patch_onlyoffice_to_enabled_editing_mode_on_mobile.sh
sed -i 's/isSupportEditFeature:function\(\)\{return!1\}/isSupportEditFeature:function(){return 1}/' -r /var/www/onlyoffice/documentserver/web-apps/apps/*/mobile/app.js
zEOFz

### Restart Onlyoffice ###
docker-compose restart onlyoffice

