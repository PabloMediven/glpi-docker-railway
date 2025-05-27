FROM php:8.2-apache

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    unzip wget libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libxml2-dev git \
    && docker-php-ext-install mysqli pdo pdo_mysql zip xml gd \
    && a2enmod rewrite

# Configura el DocumentRoot a /var/www/public
ENV APACHE_DOCUMENT_ROOT=/var/www/public

# Reescribe el archivo de Apache para que use /var/www/public como raíz
RUN sed -i "s|/var/www/html|/var/www/public|g" /etc/apache2/sites-available/000-default.conf

# Descarga y descomprime GLPI
WORKDIR /var/www
RUN wget -q https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
    tar -xzf glpi-10.0.15.tgz && \
    mv glpi glpi && \
    rm glpi-10.0.15.tgz

# Crea directorios externos recomendados por FHS
RUN mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi

# Mueve config y files a ubicaciones seguras
RUN mv /var/www/glpi/config/* /etc/glpi/ && \
    mv /var/www/glpi/files/* /var/lib/glpi/ && \
    rm -rf /var/www/glpi/config /var/www/glpi/files && \
    mkdir /var/www/glpi/config /var/www/glpi/files

# Copia downstream.php para cargar config externa
RUN echo "<?php\n\
define('GLPI_CONFIG_DIR', '/etc/glpi/');\n\
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {\n\
   require_once GLPI_CONFIG_DIR . '/local_define.php';\n\
}" > /var/www/glpi/inc/downstream.php

# Crea local_define.php con rutas externas
RUN echo "<?php\n\
define('GLPI_VAR_DIR', '/var/lib/glpi');\n\
define('GLPI_LOG_DIR', '/var/log/glpi');" > /etc/glpi/local_define.php

# Crea subdirectorios necesarios en /var/lib/glpi
RUN mkdir -p /var/lib/glpi/_cache \
    /var/lib/glpi/_cron \
    /var/lib/glpi/_dumps \
    /var/lib/glpi/_graphs \
    /var/lib/glpi/_lock \
    /var/lib/glpi/_pictures \
    /var/lib/glpi/_plugins \
    /var/lib/glpi/_rss \
    /var/lib/glpi/_sessions \
    /var/lib/glpi/_tmp \
    /var/lib/glpi/_uploads

# Da permisos al usuario de Apache (www-data)
RUN chown -R www-data:www-data /var/lib/glpi /var/log/glpi /etc/glpi

# Crea carpeta pública y redirige a GLPI
RUN mkdir -p /var/www/public && \
    echo "<?php\nheader('Location: /glpi/');\nexit;" > /var/www/public/index.php && \
    echo "" > /var/www/public/.htaccess

# Exponer puerto por defecto de Apache
EXPOSE 80
