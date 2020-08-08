FROM php:7.4-fpm

# Copy composer.lock and composer.json
COPY ./services/santex/composer.lock ./services/santex/composer.json /var/www/santex/

# Set working directory
WORKDIR /var/www/santex

# Install dependencies
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
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY ./santex /var/www/santex

RUN composer install && php artisan key:generate && npm i && npm run production

# Copy existing application directory permissions
COPY --chown=www:www ../services/santex /var/www/santex

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]