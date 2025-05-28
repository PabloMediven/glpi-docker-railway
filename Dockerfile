FROM php:8.2-apache

# 1. Actualizamos repos y dependencias necesarias
RUN apt-get update && apt-get install -y \
    unzip wget curl gnupg2 lsb-release \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev zlib1g-dev \
    libicu-dev libonig-dev mariadb-server \
    mariadb-client git supervisor \
    && apt-get clean

# 2. Configurar Apache
RUN a2enmod rewrite

# 3. Instalar extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mysqli gd xml intl mbstring opcache

# 4. Descargar GLPI
ENV GLPI_VERSION=10.0.14
RUN wget -O /tmp/glpi.tgz https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz \
    && tar -xvzf /tmp/glpi.tgz -C /var/www/html \
    && rm /tmp/glpi.tgz \
    && chown -R www-data:www-data /var/www/html/glpi

# 5. Configurar supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 6. Exponer puerto
EXPOSE 80

# 7. Comando de entrada
CMD ["/usr/bin/supervisord", "-n"]
