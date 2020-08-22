FROM php:7.4-apache

RUN sed -ri -e 's!/var/www/html!/var/www/html/santex/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/var/www/html/santex/pablic!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && sed -i "/^\s*Listen 80/c\Listen 8080" /etc/apache2/*.conf \
    && sed -i "/^\s*<VirtualHost \*:80>/c\<VirtualHost \*:8080>" /etc/apache2/sites-available/*.conf \
    && sed -i "/^\s*Require all denied/c\Require all granted" /etc/apache2/apache2.conf

WORKDIR /var/www/html/santex

RUN apt-get update && apt-get install -y \
    build-essential \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \
    libfreetype6 \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    bash

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql zip exif pcntl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www

COPY ./santex-service /var/www/html/santex 

COPY --chown=www:www ./santex-service /var/www/html/santex

RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash - \
    && apt-get -y install nodejs

RUN composer install \
    && npm i \
    && npm run production \
    && service apache2 restart

USER www
