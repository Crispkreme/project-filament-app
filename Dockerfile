# Use an official PHP image with PHP 8.3
FROM php:8.3.10-fpm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libwebp-dev \
    npm \
    libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory inside the container
WORKDIR /var/www/html/

# Copy the application files from the host to the container
COPY . .

# Ensure the necessary directories exist and set the correct permissions
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Laravel Sail dependencies
RUN composer require laravel/sail --dev

# Install Filament Admin with proper dependency resolution
RUN composer require filament/filament:"^3.2" -W --ignore-platform-req=ext-intl

# Ensure `package.json` exists before running npm install
RUN [ -f /var/www/html/package.json ] \
    && npm install \
    || echo "package.json not found, skipping npm install"

# Run Laravel Sail installation with required services
# RUN php artisan sail:install --with=mysql,redis,meilisearch,mailhog,selenium \
#     && php artisan filament:install --panels && php artisan key:generate

# Expose the application port
EXPOSE 8000

# Start Laravel Sail when the container is started
CMD ["./vendor/bin/sail", "up"]
