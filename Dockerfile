FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    libxml2-dev zip libzip-dev libicu-dev libmariadb-dev \
    && docker-php-ext-install pdo pdo_mysql mysqli gd intl xml zip \
    && a2enmod rewrite

# Instalar Composer (versión 2)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clonar GLPI
WORKDIR /var/www/html
RUN git clone https://github.com/glpi-project/glpi.git .

# Instalar dependencias PHP de GLPI
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs
RUN php bin/console dependencies install --no-interaction

# Configurar Apache para que apunte a /public
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf
