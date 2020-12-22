FROM ubuntu:18.04

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
    supervisor \
    apt-utils \
    curl \
    git \
    software-properties-common \
    # Install php 7.2
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    php-imagick \
    # Install tools
    openssl \
    vim \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    locales \
    sqlite3 \
    ca-certificates \
    net-tools \
    sudo \
    wget \
    cmake \
    build-essential \
    nano \
    g++ \
    kmod \
    linux-image-$(uname -r) \
    linux-headers-$(uname -r) \
    libprotobuf-dev \
    protobuf-compiler \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
#RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
#RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
#RUN docker-php-ext-install gd

# Set user for laravel application
RUN deluser www-data
RUN groupadd -g 1000 www-data
RUN useradd -u 1000 -ms /bin/bash -g www-data www-data
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy existing application directory contents
COPY . /var/www

# Set application directory permissions in container
RUN chown -R www-data:www-data . /var/www

# Make php-fpm runnable
RUN mkdir -p /var/run/php

# Since php-fpm and nginx are in separate containers, we need to make php-fpm listen 0.0.0.0 which means: any interface of the php-fpm container
RUN sed -e 's/listen =.*/listen = 0.0.0.0:9000/' -i /etc/php/7.2/fpm/pool.d/www.conf

# Expose port 9000 and start php server
EXPOSE 9000
ENTRYPOINT ["/usr/sbin/php-fpm7.2", "-c", "/etc/php/7.2/fpm/php-fpm.conf", "-F"]