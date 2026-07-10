FROM php:8.1-apache-bookworm

# Use the default production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install system dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libmagickwand-dev \
    unzip \
    git \
    > /dev/null && rm -rf /var/lib/apt/lists/*

# Configure and install core PHP extensions (non-PECL)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    gd \
    pdo_mysql \
    zip

# Compile and install Imagick from source to bypass PECL XML channel errors
RUN git clone --branch 3.7.0 --depth 1 https://github.com/Imagick/imagick.git /tmp/imagick \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/imagick

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
