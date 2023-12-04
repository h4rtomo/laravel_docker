# Use the official PHP image with PHP 8.1
FROM php:8.1-fpm

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql zip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy application files
COPY ./laravel-app /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1

# Install application dependencies
RUN composer install --optimize-autoloader --no-interaction

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]

