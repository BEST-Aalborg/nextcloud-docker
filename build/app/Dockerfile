ARG IMAGE_TAG
FROM nextcloud:${IMAGE_TAG}
ARG IMAGE_TAG
RUN echo "NextCloud tag: ${IMAGE_TAG}" | tee /tmp/IMAGE_TAG


### Tune PHP-FPM
# Ref: https://docs.nextcloud.com/server/19/admin_manual/installation/server_tuning.html?highlight=memory%20limit#tune-php-fpm
RUN sed -i 's/.*pm.max_children.*/pm.max_children = 300/'                         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.start_servers.*/pm.start_servers = 18/'                        /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.min_spare_servers.*/pm.min_spare_servers = 18/'                /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.max_spare_servers.*/pm.max_spare_servers = 32/'                /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.process_idle_timeout.*/pm.process_idle_timeout = 30s/'         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.max_requests.*/pm.max_requests = 500/'                         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/opcache.memory_consumption.*[0-9]*/opcache.memory_consumption=384/' /usr/local/etc/php/conf.d/opcache-recommended.ini \
 && true

### Installs the missing packages for php-imagick (SVG support)
# Message in Security & setup warnings:
#
# Module php-imagick in this instance has no SVG support. For better compatibility it is recommended to install it
RUN apt-get update \
 && apt-get install --yes \
        libmagickcore-6.q16-6-extra \
        ffmpeg \
 && rm -rf /var/lib/apt/lists/*

### Installs the missing packages for samba (Windows Share)
#RUN apt-get update \
# && apt-get install --yes smbclient libsmbclient-dev \
# && pecl install smbclient \
# && docker-php-ext-enable smbclient \
# && rm -rf /var/lib/apt/lists/*

ARG XDEBUG_MODE
RUN yes | pecl install xdebug \
 && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.mode=${XDEBUG_MODE}" 						>> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" 				>> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.client_port=9003" 						>> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.start_with_request=yes" 					>> /usr/local/etc/php/conf.d/xdebug.ini \
 && true



# RUN rm -rf /etc/cron* \
#  && echo 'SHELL=/bin/sh' >> /etc/crontab \
#  && echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' \
#  && echo '# Example of job definition:' \
#  && echo '# .---------------- minute (0 - 59)' \
#  && echo '# |  .------------- hour (0 - 23)' \
#  && echo '# |  |  .---------- day of month (1 - 31)' \
#  && echo '# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...' \
#  && echo '# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat' \
#  && echo '# |  |  |  |  |' \
#  && echo '*/4  *  *  *  *  www-data cd /var/www/html &&'



