FROM php:5.6-apache
LABEL maintainer=brisaning@gmail.com

RUN apt update

RUN apt install -y libmemcached-dev zlib1g-dev curl wget \
libpng-dev libc-client-dev libkrb5-dev libmcrypt-dev \
zlib1g-dev libicu-dev libpq-dev libxml2-dev zip unzip


RUN docker-php-ext-install mysqli mysql \
calendar exif gd bcmath mcrypt \
pcntl pdo_mysql intl \
pdo_pgsql pgsql soap sockets zip

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap

# mcrypt
#RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
#&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#&& docker-php-ext-install -j$(nproc) gd

RUN pecl install memcached-2.2.0
RUN pecl install memcache

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

RUN rm -r /var/lib/apt/lists/*

WORKDIR /var/www/localhost/htdocs