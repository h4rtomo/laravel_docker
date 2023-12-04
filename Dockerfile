FROM php:8.2-fpm

# Copy composer.lock and composer.json
COPY ./laravel-app/composer.lock /var/www/composer.lock
COPY ./laravel-app/composer.json /var/www/composer.json

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    php8.2-fpm \
    php8.2-xml \
    php8.2-json \
    php8.2-mbstring \
    php8.2-curl \
    zip \
    unzip \
    php8.2-gd \
    php8.2-zip \
    php8.2-pear \
    php8.2-dev \
    php8.2-mysql 

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
# RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]