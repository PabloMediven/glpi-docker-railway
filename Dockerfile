FROM php:8.2-apache

# Requisitos del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libldap2-dev \
    libmariadb-dev \
    libmariadb-dev-compat \
    mariadb-client \
    git \
    && docker-php-ext-install intl pdo pdo_mysql gd xml ldap opcache

# Instalar Composer (opcional pero útil)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Crear rutas seguras
RUN mkdir -p /etc/glpi /var/lib/glpi /var/log/glpi /var/www/glpi /var/www/public

# Crear subdirectorios requeridos por GLPI
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

# Descargar y extraer GLPI
WORKDIR /var/www/glpi
RUN wget -q https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz && \
    tar -xzf glpi-10.0.15.tgz --strip-components=1 && \
    rm glpi-10.0.15.tgz

# Mover configuraciones y archivos a rutas seguras
RUN mv config/* /etc/glpi/ && \
    mv files/* /var/lib/glpi/ || true && \
    rm -rf config files && \
    mkdir config files

# Redirección desde /var/www/public al GLPI real
RUN echo "<?php\nheader('Location: /glpi/');\nexit;" > /var/www/public/index.php && \
    touch /var/www/public/.htaccess

# Definiciones locales para rutas seguras
RUN echo "<?php\n"\
"define('GLPI_CONFIG_DIR', '/etc/glpi/');\n"\
"define('GLPI_VAR_DIR', '/var/lib/glpi');\n"\
"define('GLPI_LOG_DIR', '/var/log/glpi');\n"\
"?>" > /etc/glpi/local_define.php

# Configuración de PHP para seguridad de sesiones
RUN echo "session.cookie_httponly=On" > /usr/local/etc/php/conf.d/security.ini

# Permisos correctos
RUN chown -R www-data:www-data /etc/glpi /var/lib/glpi /var/log/glpi /var/www/glpi && \
    chmod -R 750 /etc/glpi /var/lib/glpi /var/log/glpi

# Copiar configuración de Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Activar módulo rewrite
RUN a2enmod rewrite

# Exponer puerto y arrancar
EXPOSE 80
CMD ["apache2-foreground"]
