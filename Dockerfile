ARG PHP_VERSION=7.3
ARG ALPINE_VERSION=3.10

FROM php:${PHP_VERSION}-zts-alpine${ALPINE_VERSION}

LABEL Description="Application container"

ENV PS1='🐳 \[\033[1;36m\]\D{%F} \[\033[0;31m\]\t \[\033[0;32m\][\[\033[1;34m\]\u\[\033[1;97m\]@\[\033[1;93m\]\h\[\033[0;32m\]] \[\033[0;95m\]\w \[\033[1;36m\]#\[\033[0m\] '

## Looked here: <https://github.com/prooph/docker-files/blob/master/php/7.2-cli>
ARG REDIS_VERSION=5.2.1

ARG PHP_EXTENSIONS="\
    bcmath \
    gmp \
    gd \
    intl \
    pcntl \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    soap \
    iconv \
    bz2 \
    calendar \
    exif \
    gettext \
    shmop \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    wddx \
    xsl \
    zip"

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV PATH /scripts:/scripts/aliases:$PATH

COPY composer.sh /

ARG UTILS="\
    bash \
    nano \
    curl \
    git \
    unzip \
    graphviz \
    netcat-openbsd \
    mysql-client \
    openssh \
    postgresql-client \
    procps \
    shadow \
    coreutils"

ARG PHP_BUILD_DEPS="\
    autoconf \
    cmake \
    file \
    g++ \
    gcc \
    libc-dev \
    pcre-dev \
    make \
    freetype-dev \
    gmp-dev \
    icu-dev \
    pkgconf \
    re2c \
    libxml2-dev \
    postgresql-dev \
    freetype-dev \
    libpng-dev  \
    libevent-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    imagemagick-dev \
    bzip2-dev \
    libzip-dev \
    gettext-dev \
    libxslt-dev"

ARG PHP_RUN_DEPS="\
    icu-libs \
    libbz2 \
    libxslt \
    libpng \
    freetype \
    libxpm \
    libwebp \
    imagemagick \
    libxml2 \
    libevent \
    libintl \
    ttf-freefont \
    libjpeg-turbo \
    libzip \
    gmp"

RUN apk add --no-cache ${UTILS} ${PHP_RUN_DEPS}\
    && set -xe \
    # workaround for rabbitmq linking issue
    && ln -s /usr/lib /usr/local/lib64 \
    && \
    apk add --no-cache --virtual .php-build-deps ${PHP_BUILD_DEPS} \
    && docker-php-ext-configure gd \
      --disable-gd-jis-conv \
      --with-freetype-dir=/usr \
      --with-jpeg-dir=/usr \
      --with-webp-dir=/usr \
      --with-xpm-dir=/usr \
    && docker-php-ext-install -j$(nproc) ${PHP_EXTENSIONS} \
    && \
    pecl install -o -f redis-${REDIS_VERSION} event imagick \
    && docker-php-ext-enable ${PHP_EXTENSIONS} redis imagick event \
    # Rename docker-php-ext-event.ini -> docker-php-ext-zz-event.ini to load it after docker-php-ext-sockets.ini https://github.com/docker-library/php/issues/857
    && mv /usr/local/etc/php/conf.d/docker-php-ext-event.ini /usr/local/etc/php/conf.d/docker-php-ext-zz-event.ini \
    && apk del --no-cache .php-build-deps \
    && rm -rf \
      /tmp/* \
      /app \
      /scripts \
      /home/user \
    && rm -f \
      /docker-entrypoint.sh \
      /usr/local/etc/php-fpm.d/* \
    && mkdir -p \
      /scripts/aliases \
      /app \
      /home/user \
      "$COMPOSER_HOME" \
    && chmod 777 /home/user \
    # install composer
    && /composer.sh "$COMPOSER_HOME" \
    && rm -f /composer.sh \
    && composer --ansi --version --no-interaction \
    && composer --no-interaction global --prefer-stable require 'hirak/prestissimo' \
    && composer --no-interaction global --prefer-stable require 'ergebnis/composer-normalize' \
    && composer clear-cache \
    && rm -rf /tmp/composer-setup.php /tmp/.htaccess /tmp/cache \
    && php -v \
    && php -m


COPY ./aliases/* /scripts/aliases/
COPY ./etc/bin/* /usr/local/bin/
COPY ./keep-alive.sh /scripts/keep-alive.sh
COPY ./fpm-entrypoint.sh /fpm-entrypoint.sh
COPY ./fpm-command.sh /fpm-command.sh
COPY ./etc/php/php-dev.ini /usr/local/etc/php/php.ini
COPY ./etc/php/php-fpm.conf /usr/local/etc/php-fpm.conf

WORKDIR /var/www
ENTRYPOINT []
CMD []
