FROM php:7.4-fpm

ARG BUILD_DATE
ARG REVISION

LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.vendor="WickedByte LLC"
LABEL org.opencontainers.image.authors="Andy Snell <andy@wickedbyte.com>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="PHP-FPM 7.4 Runtime for Laravel"
LABEL org.opencontainers.image.description="PHP-FPM 7.4 image tailored for development with Laravel >= 7"
LABEL org.opencontainers.image.source="https://github.com/wickedbyte/docker-for-laravel"
LABEL org.opencontainers.image.version="0.0.1"
LABEL org.opencontainers.image.revision=$REVISION

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    redis-tools \
    libpng-dev \
    libxml2-dev \
    libgmp3-dev \
    default-mysql-client \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install -j$(nproc) pdo_mysql zip exif bcmath pcntl gd gmp soap
RUN pecl install redis && docker-php-ext-enable redis
RUN pecl install ds && docker-php-ext-enable ds
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Configure INI settings
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/settings.ini; \
    echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/settings.ini; \
    echo "display_errors = On" >> /usr/local/etc/php/conf.d/settings.ini;

# Install composer and allow docker to install dependencies without root warnings
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer;
RUN composer global require hirak/prestissimo icanhazstring/composer-unused
RUN composer global require --update-no-dev --prefer-dist \
        psy/psysh:@stable \
        nesbot/carbon \
        laravel/installer \
        laravel-zero/installer

# Copy over aliases and PATH
COPY .bashrc /root/.bashrc