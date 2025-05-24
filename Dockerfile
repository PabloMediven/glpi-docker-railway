FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    libxml2-dev zip libzip-dev libicu-dev libmcrypt-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd intl

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Clonar GLPI
WORKDIR /var/www/html
RUN git clone https://github.com/glpi-project/glpi . 

# Instalar dependencias PHP de GLPI
RUN composer install --no-dev --optimize-autoloader

# Configurar Apache para que apunte a /public
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Ajustar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
