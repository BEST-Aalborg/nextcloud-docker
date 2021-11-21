FROM onlyoffice/documentserver:latest

### Why is this needed? ###
# Because OnlyOffice decited that since they had become official supported by Nextcloud it was time to remove simple free features :‘(
#
# OnlyOffice removed the function to edit document in the web-browser on mobile platforms from there DocumentServer Community Edition
# Source: https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360
#
# There exists a fix which is easy to implement and that is what this script does.
# The fix is from the 23/03/2020 and I (Dennis) don't for how long it will work,
# but if we no longer can edit document on our mobile devices in the web-browser when it probably stopped working
# https://help.nextcloud.com/t/onlyoffice-removed-web-mobile-editing-from-version-5-5-0-of-community-document-server/74360/46
#
# Update: 2021-11-21
# I found that the replace command no long works. It seems to be because the file moved place and the code have also change slightly.
# I have there for tried to make a command there is a little more flexible
#
# DocumentServer - https://github.com/ONLYOFFICE/DocumentServer.


### Applying the patch ###
# by replace
# isSupportEditFeature:function(){return!1}
# with
# isSupportEditFeature:function(){return 1}

# Worked on the 23/03/2020 with version 5.5.0
# RUN sed -i 's/isSupportEditFeature:function\(\)\{return!1\}/isSupportEditFeature:function(){return 1}/' -r /var/www/onlyoffice/documentserver/web-apps/apps/*/mobile/app.js

# Worked on the 21/11/2021 with version 6.4.0
RUN find /var/www/onlyoffice/documentserver/web-apps/apps/*/mobile -name app.js | xargs -n 1 sed -i -E 's/isSupportEditFeature(.)function\(\)\{return!([0-1])\}/isSupportEditFeature\1function(){return \2}/'

