FROM php:8.2-apache

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install system utilities
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Add docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install PHP extensions using the installer
RUN install-php-extensions \
    gd \
    pdo_mysql \
    zip \
    fileinfo \
    mbstring \
    curl \
    imagick

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Enable AllowOverride in Apache configs to make .htaccess work
RUN sed -ri -e 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Set ownership of all files to Apache's default user
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

