FROM php:5.6-apache

RUN apt-get update && \
    apt install -y \
        libmemcached-dev \
        zlib1g-dev \
        git \
        curl \
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
        libxext6 && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include && \
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
# This command fails
# RUN pecl install memcache
RUN pecl install xdebug-2.5.5
RUN pecl install apcu-4.0.11

RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Recreate user with correct params
RUN groupmod -g 1000 www-data && \
    usermod -u 1000 www-data

# Symfony 1
COPY ./symfony /var/www/symfony

# Symfony 3
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
RUN chmod a+x /usr/local/bin/symfony

# PDF
COPY ./wkhtmltox /opt/wkhtmltox/bin

WORKDIR /var/www/localhost/htdocs