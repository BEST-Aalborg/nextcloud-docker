ARG IMAGE_TAG
FROM nextcloud:${IMAGE_TAG} as dlib-builder

RUN apt-get update \
 && apt-get install --yes build-essential wget jq cmake libx11-dev libopenblas-dev liblapack-dev unzip git


# Build and install dlib on builder
RUN cd \
 && DLIB_BRANCH="$(wget --quiet --output-document=- 'https://api.github.com/repos/davisking/dlib/releases/latest' | jq -r '.tag_name')" \
 && wget -c -q https://github.com/davisking/dlib/archive/$DLIB_BRANCH.tar.gz \
 && tar xf $DLIB_BRANCH.tar.gz \
 && mv dlib-* dlib \
 && cd dlib/dlib \
 && mkdir build \
 && cd build \
 && cmake -DBUILD_SHARED_LIBS=ON .. \
 && make \
 && make install


# Build and install PDLib on builder
RUN cd \
 && git clone https://github.com/goodspb/pdlib.git \
 && cd pdlib \
 && phpize \
 && ./configure \
 && make \
 && make install \
 && mv /usr/local/lib/php/extensions/no-debug-non-zts-*/pdlib.so /usr/local/lib/php/extensions/pdlib.so



ARG IMAGE_TAG
FROM nextcloud:${IMAGE_TAG}
ARG IMAGE_TAG
RUN echo "NextCloud tag: ${IMAGE_TAG}" | tee /tmp/IMAGE_TAG

### Installs the missing packages for php-imagick (SVG support)
# Message in Security & setup warnings:
#
# Module php-imagick in this instance has no SVG support. For better compatibility it is recommended to install it
RUN apt-get update \
 && apt-get install --yes \
        libmagickcore-6.q16-6-extra \
        ffmpeg \
        libbz2-dev \
        libopenblas-dev \
 && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-install bz2

ARG XDEBUG_MODE
RUN yes | pecl install xdebug \
 && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)"  > /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.mode=${XDEBUG_MODE}"                                            >> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal"                               >> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.client_port=9003"                                               >> /usr/local/etc/php/conf.d/xdebug.ini \
 && echo "xdebug.start_with_request=yes"                                         >> /usr/local/etc/php/conf.d/xdebug.ini \
 && true


### Tune PHP-FPM
# Ref: https://docs.nextcloud.com/server/19/admin_manual/installation/server_tuning.html?highlight=memory%20limit#tune-php-fpm
RUN sed -i 's/.*pm.max_children.*/pm.max_children = 300/'                         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.start_servers.*/pm.start_servers = 18/'                        /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.min_spare_servers.*/pm.min_spare_servers = 18/'                /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.max_spare_servers.*/pm.max_spare_servers = 32/'                /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.process_idle_timeout.*/pm.process_idle_timeout = 30s/'         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/.*pm.max_requests.*/pm.max_requests = 500/'                         /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/opcache.memory_consumption.*[0-9]*/opcache.memory_consumption=384/' /usr/local/etc/php/conf.d/opcache-recommended.ini \
 && echo "extension=/usr/local/lib/php/extensions/pdlib.so"                                                   > /usr/local/etc/php/conf.d/pdlib.ini \
 && true


# Install dlib.so and PDlib to image.so
COPY --from=dlib-builder /usr/local/lib/libdlib.so* /usr/local/lib
COPY --from=dlib-builder /usr/local/lib/php/extensions/pdlib.so /usr/local/lib/php/extensions/pdlib.so


### Installs the missing packages for samba (Windows Share)
#RUN apt-get update \
# && apt-get install --yes smbclient libsmbclient-dev \
# && pecl install smbclient \
# && docker-php-ext-enable smbclient \
# && rm -rf /var/lib/apt/lists/*




