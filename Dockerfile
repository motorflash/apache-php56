FROM php:5.6-apache

RUN apt-get update && \
    apt install -y \
        curl \
        apt-transport-https \
        ca-certificates \
        gnupg2

# Install Node repository #
RUN echo "deb https://deb.nodesource.com/node_10.x stretch main\n\
deb-src https://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list && \
    curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

RUN apt-get update && \
    apt install -y \
        expect \
        libmemcached-dev \
        zlib1g-dev \
        git \
        vim \
        nano \
        wget \
        libpng-dev \
        libc-client-dev \
        libkrb5-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev \
        libpq-dev \
        libxml2-dev \
        zip \
        unzip \
        libxslt-dev \
        freetype* \
        libmagickwand-dev --no-install-recommends \
        libfontconfig1 \
        libxrender1 \
        libxext6 \
        libvpx-dev \
        nodejs \
        openssh-server \
        webp \
        locales && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
            --enable-gd-native-ttf \
            --with-freetype-dir=/usr/include/freetype2 \
            --with-png-dir=/usr/include \
            --with-jpeg-dir=/usr/include \
            --with-vpx-dir \
            --with-webp && \
    docker-php-ext-configure imap \
        --with-kerberos \
        --with-imap-ssl && \
    docker-php-ext-install \
        gd \
        imap \
        mysqli \
        mysql \
        calendar \
        exif \
        bcmath \
        mcrypt \
        pcntl \
        pdo_mysql \
        intl \
        pdo_pgsql \
        pgsql \
        soap \
        sockets \
        zip \
        xsl

RUN pecl install imagick
RUN pecl install memcached-2.2.0
RUN yes|CFLAGS="-fgnu89-inline" pecl install memcache-3.0.8
RUN pecl install xdebug-2.5.5
RUN pecl install apcu-4.0.11

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install locale env
RUN touch /etc/locale.gen \
    && sed -i -e 's/# es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && update-locale LC_ALL="es_ES.UTF-8"
ENV LANG es_ES.UTF-8
ENV LANGUAGE es_ES:en
ENV LC_ALL es_ES.UTF-8

# Recreate user with correct params
RUN groupmod -g 1000 www-data && \
    usermod -u 1000 www-data

# Symfony 3
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
RUN chmod a+x /usr/local/bin/symfony

# PDF
COPY ./wkhtmltox /opt/wkhtmltox/bin

WORKDIR /var/www/localhost/htdocs