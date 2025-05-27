FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git unzip wget \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip xml opcache

# Activar mod_rewrite en Apache
RUN a2enmod rewrite

# Crear carpetas necesarias para configuración segura
RUN mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi

RUN chown -R www-data:www-data /etc/glpi /var/lib/glpi /var/log/glpi && \
    chmod -R 750 /etc/glpi /var/lib/glpi /var/log/glpi


# Descargar y extraer GLPI
WORKDIR /var/www
RUN wget -q https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
    tar -xzf glpi-10.0.15.tgz && rm glpi-10.0.15.tgz

# Mover config y files a ubicaciones seguras
RUN if [ -d /var/www/glpi/config ]; then \
        cp -r /var/www/glpi/config/* /etc/glpi/ 2>/dev/null || true; \
        rm -rf /var/www/glpi/config; \
    fi && \
    if [ -d /var/www/glpi/files ]; then \
        cp -r /var/www/glpi/files/* /var/lib/glpi/ 2>/dev/null || true; \
        rm -rf /var/www/glpi/files; \
    fi && \
    mkdir -p /var/www/glpi/config /var/www/glpi/files


# Crear archivo downstream.php que use los paths externos
RUN echo "<?php\n\
define('GLPI_CONFIG_DIR', '/etc/glpi/');\n\
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {\n\
    require_once GLPI_CONFIG_DIR . '/local_define.php';\n\
}" > /var/www/glpi/inc/downstream.php

# Crear archivo local_define.php para configurar los paths
RUN echo "<?php\n\
define('GLPI_VAR_DIR', '/var/lib/glpi');\n\
define('GLPI_LOG_DIR', '/var/log/glpi');" > /etc/glpi/local_define.php

# Crear carpeta pública y redirección
RUN mkdir -p /var/www/public && \
    printf "<?php\nheader('Location: /glpi/');\nexit;\n" > /var/www/public/index.php && \
    touch /var/www/public/.htaccess

# Apache config personalizado
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
