FROM php:8.2-apache

# Instalar dependencias necesarias para PHP
RUN apt-get update && apt-get install -y \
    git unzip wget \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip xml opcache

# Activar mod_rewrite en Apache
RUN a2enmod rewrite

# Configurar PHP para mayor seguridad
RUN echo "session.cookie_httponly=On" > /usr/local/etc/php/conf.d/session.ini

# Crear estructura de carpetas
WORKDIR /var/www
RUN mkdir public

# Descargar y extraer GLPI (versión actualizada si querés)
RUN wget -q https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz
RUN tar -xzf glpi-10.0.15.tgz
RUN rm glpi-10.0.15.tgz
RUN mv glpi glpi-back && \
    mv glpi-back/* glpi && \
    rm -rf glpi-back && \
    chown -R www-data:www-data /var/www && chmod -R 755 /var/www



# Crear archivo index.php en public/ que apunte a GLPI
RUN echo "<?php\nrequire __DIR__ . '/../glpi/index.php';" > /var/www/public/index.php

# (Opcional) Crear .htaccess vacío en public
RUN echo "" > /var/www/public/.htaccess

# Apache config para usar public/ como DocumentRoot
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Entrypoint personalizado
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
