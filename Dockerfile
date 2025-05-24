FROM php:8.2-apache

# Instalar extensiones necesarias
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

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Establecer el DocumentRoot
RUN echo "DocumentRoot /var/www/html/glpi" > /etc/apache2/sites-enabled/000-default.conf

# El buildCommand en render.yaml hará el clon del repositorio GLPI
