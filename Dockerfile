FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd

# Clonar GLPI dentro del DocumentRoot por defecto
RUN git clone https://github.com/glpi-project/glpi.git /var/www/html

# Establecer permisos apropiados para Apache
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Asegurar acceso desde Apache
RUN printf '%s\n' \
"<VirtualHost *:80>" \
"    DocumentRoot /var/www/html" \
"    <Directory /var/www/html>" \
"        Options Indexes FollowSymLinks" \
"        AllowOverride All" \
"        Require all granted" \
"    </Directory>" \
"</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

