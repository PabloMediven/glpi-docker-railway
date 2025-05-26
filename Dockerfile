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

# Configurar PHP para seguridad de sesión
RUN echo "session.cookie_httponly=On" > /usr/local/etc/php/conf.d/session.ini

# Crear estructura
WORKDIR /var/www
RUN mkdir glpi public

# Descargar GLPI 10.0.16
# Descargar GLPI 10.0.18
RUN wget -O glpi.tgz https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
    tar -xvzf glpi.tgz && \
    rm glpi.tgz && \
    mv glpi/* . && rm -rf glpi && \
    chown -R www-data:www-data . && chmod -R 755 .

#RUN wget -q https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
#    tar -xzf glpi-10.0.15.tgz && \
#    rm glpi-10.0.15.tgz && \
#    mv glpi-10.0.15 glpi && \
#    chown -R www-data:www-data . && chmod -R 755 .
    
# Crear index.php en /public que apunta a /glpi/index.php
RUN echo "<?php require __DIR__ . '/../glpi/install/install.php';" > public/index.php

# .htaccess opcional (vacío o con reglas)
RUN echo "" > public/.htaccess

# Apache config
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
