FROM debian:bookworm

# Dependencias básicas
RUN apt update && apt install -y \
    apache2 libapache2-mod-php php php-mysql mariadb-client \
    php-curl php-mbstring php-xml php-zip php-gd php-intl php-bz2 php-ldap php-apcu \
    wget unzip nano supervisor curl php-soap php-xmlrpc php-bcmath php-imap \
    && apt clean

# Descargar GLPI
RUN wget https://github.com/glpi-project/glpi/releases/download/10.0.14/glpi-10.0.14.tgz \
    && tar -xvzf glpi-10.0.14.tgz -C /var/www/html/ \
    && rm glpi-10.0.14.tgz

# Permisos
RUN chown -R www-data:www-data /var/www/html/glpi

# Apache config
COPY glpi.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Supervisord para iniciar Apache
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]
