FROM php:5.6-apache

RUN apt-get update && \
    apt install -y \
        curl \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        wget

# Install Node repository #
RUN echo "deb https://deb.nodesource.com/node_10.x stretch main\n\
deb-src https://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list && \
    curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

# Install Chrome repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1

RUN apt-get update && \
    apt install -y \
        expect \
        libmemcached-dev \
        zlib1g-dev \
        git \
        vim \
        nano \
        libpng-dev \
        libc-client-dev \
        libkrb5-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev \
        libpq-dev \
        libxml2-dev \
        iputils-ping \
        telnet \
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
        locales \
        openjdk-8-jdk \
        ant \
        ca-certificates-java \
        google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Update certificates for OpenJDK-8
RUN update-ca-certificates -f

# Setup JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Add selenium user
RUN useradd -ms /bin/bash selenium

# Install selenium and chromedriver
RUN wget -q -P /home/selenium/ https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar
RUN wget -q -P /home/selenium/ https://chromedriver.storage.googleapis.com/85.0.4183.87/chromedriver_linux64.zip
RUN unzip /home/selenium/chromedriver_linux64.zip -d /home/selenium/
RUN mv -f /home/selenium/chromedriver /usr/local/share/
RUN chmod +x /usr/local/share/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
RUN ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

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

# Recreate users with correct params
RUN groupmod -g 1002 selenium && \
    usermod -u 1002 selenium
RUN groupmod -g 1000 www-data && \
    usermod -u 1000 www-data

# PDF
COPY ./wkhtmltox /opt/wkhtmltox/bin

WORKDIR /var/www/localhost/htdocs

