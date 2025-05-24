FROM php:8.2-apache

# Instalar extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip wget \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip xml opcache

# Activar mod_rewrite
RUN a2enmod rewrite

# Configuración PHP para cookies seguras
RUN echo "session.cookie_httponly=On" > /usr/local/etc/php/conf.d/session.ini

# Crear estructura de carpetas
WORKDIR /var/www
RUN mkdir glpi public

# Descargar GLPI
RUN wget -O glpi.tgz https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
    tar -xvzf glpi.tgz && rm glpi.tgz && \
    mv glpi/* glpi/ && rm -rf glpi && \
    chown -R www-data:www-data glpi

# Crear index.php en public que apunta a glpi
RUN echo "<?php require __DIR__ . '/../glpi/index.php';" > public/index.php

# Crear .htaccess (puede ser vacío si usás reglas en apache.conf)
RUN echo "" > public/.htaccess

# Configurar Apache para servir desde /var/www/public
COPY apache.conf /etc/apache2/sites-available/000-default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
