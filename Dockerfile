# Usa una imagen base de Alpine + Apache + PHP
FROM php:8.1-apache

# Instala extensiones necesarias para GLPI
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev zip unzip git mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli gd xml intl mbstring opcache \
    && apt-get clean

# Descarga GLPI
RUN curl -L https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz | tar xz -C /var/www/html --strip-components=1

# Asigna permisos adecuados
RUN chown -R www-data:www-data /var/www/html

# Expone el puerto 80
EXPOSE 80

# Comando de inicio
CMD ["apache2-foreground"]
