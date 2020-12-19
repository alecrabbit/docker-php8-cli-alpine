ARG PHP_VERSION=8.0
ARG ALPINE_VERSION=3.12

FROM php:${PHP_VERSION}-cli-alpine${ALPINE_VERSION}

LABEL Description="DEV Application container"

ENV PS1='🐳 \[\033[1;36m\]\D{%F} \[\033[0;33m\]\t \[\033[0;32m\][\[\033[1;34m\]\u\[\033[1;97m\]@\[\033[1;93m\]\h\[\033[0;32m\]] \[\033[0;95m\]\w \[\033[1;36m\]#\[\033[0m\] '

ARG REDIS_VERSION=5.3.2
ARG EVENT_VERSION=3.0.2
ARG IMAGICK_VERSION=3.4.4

ARG COMPOSER_HOME=/tmp/composer

# Note: extensions redis, event & imagick installed separately see below

ARG PHP_EXTENSIONS="\
    bcmath \
    gmp \
    gd \
    intl \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    mysqli \
    pgsql \
    mbstring \
    soap \
    iconv \
    bz2 \
    calendar \
    exif \
    gettext \
    sockets \
    xsl \
    zip"

ARG UTILS="\
    bash \
    nano \
    curl \
    git \
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
    freetype-dev \
    libpng-dev  \
    libevent-dev \
    oniguruma-dev \
    libjpeg-turbo-dev \
    postgresql-dev \
    libwebp-dev \
    libxpm-dev \
    imagemagick-dev \
    bzip2-dev \
    libzip-dev \
    gettext-dev \
    libxslt-dev"

ARG PHP_RUN_DEPS="\
    unzip \
    graphviz \
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

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME ${COMPOSER_HOME}
ENV PATH /scripts:/scripts/aliases:$PATH

COPY composer.sh /

RUN set -eux && apk add --no-cache ${UTILS}

RUN set -eux && apk add --no-cache ${PHP_RUN_DEPS}

RUN set -eux \
    && \
    apk add --no-cache --virtual .php-build-deps ${PHP_BUILD_DEPS} \
    && docker-php-ext-configure gd \
      --disable-gd-jis-conv \
      --with-freetype=/usr \
      --with-jpeg=/usr \
      --with-webp=/usr \
      --with-xpm=/usr \
    && docker-php-ext-install -j$(nproc) ${PHP_EXTENSIONS} \
    && \
    pecl install -o -f \
      event-${EVENT_VERSION} \
      imagick-${IMAGICK_VERSION} \
      redis-${REDIS_VERSION} \
    && docker-php-ext-enable ${PHP_EXTENSIONS} event imagick redis \
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
      ${COMPOSER_HOME} \
    && chmod 777 /home/user ${COMPOSER_HOME}\
    # install composer
    && /composer.sh ${COMPOSER_HOME} \
    && rm -f /composer.sh \
    && composer --ansi --version --no-interaction \
    && composer --no-interaction global --prefer-stable require 'hirak/prestissimo' \
    && composer --no-interaction global --prefer-stable require 'ergebnis/composer-normalize' \
    && composer clear-cache \
    && rm -rf ${COMPOSER_HOME}/.htaccess ${COMPOSER_HOME}/cache /tmp/pear \
    && php -v \
    && php -m

COPY ./aliases/* /scripts/aliases/
COPY ./etc/bin/* /usr/local/bin/
COPY ./keep-alive.sh /scripts/keep-alive.sh
COPY ./etc/php/php-dev.ini /usr/local/etc/php/php.ini

WORKDIR /var/www
ENTRYPOINT []
