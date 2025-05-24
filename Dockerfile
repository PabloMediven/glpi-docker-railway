FROM php:8.2-apache

# Instalación de extensiones necesarias para GLPI
RUN apt-get update && apt-get install -y \
    git unzip wget \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip xml opcache

# Activar mod_rewrite
RUN a2enmod rewrite

# Configuración de Apache para GLPI (apunta a /var/www/html/public)
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Descargar GLPI (ajustado a la versión estable más reciente)
WORKDIR /var/www/html
RUN wget https://github.com/glpi-project/glpi/releases/latest/download/glpi.tgz && \
    tar -xvzf glpi.tgz && \
    rm glpi.tgz && \
    mv glpi/* . && rm -rf glpi && \
    chown -R www-data:www-data . && chmod -R 755 .

# Entrypoint para instalar dependencias de GLPI
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
