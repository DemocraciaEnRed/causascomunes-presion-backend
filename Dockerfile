# Based off of php 7.1.5 example: https://blog.cloud66.com/deploying-your-cakephp-applications-with-cloud-66/
FROM php:7.3.3-apache

LABEL org.opencontainers.image.source https://github.com/DemocraciaEnRed/causascomunes-presion-backend

# System dependencies
RUN apt-get update && apt-get install -y libicu-dev libpq-dev mysql-client zip unzip \
  libzip-dev zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
  && rm -r /var/lib/apt/lists/*

# Configure the php modules
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
  && docker-php-ext-install intl mbstring pcntl pdo_mysql zip opcache gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && composer self-update 1.10.24

# Set our application folder as an environment variable
ENV APP_HOME /var/www/html

# Set UID & GID to 1000 for www-data
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Change the web_root to cakephp /var/www/html/webroot folder
RUN sed -i -e "s/html/html\/webroot/g" /etc/apache2/sites-enabled/000-default.conf

# Enable apache module rewrite
RUN a2enmod rewrite

# Copy source files and run composer
COPY . $APP_HOME

# Install all PHP dependencies
RUN composer install --no-interaction

# Change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

# Set execution permission on binaries
RUN chmod 755 $APP_HOME/bin/*
