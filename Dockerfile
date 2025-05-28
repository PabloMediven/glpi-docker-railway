FROM debian:bookworm

RUN apt update && apt install -y \
    apache2 libapache2-mod-php php php-mysql mariadb-client \
    php-curl php-mbstring php-xml php-zip php-gd php-intl php-bz2 php-ldap php-apcu \
    wget unzip nano supervisor curl php-soap php-xmlrpc php-bcmath php-imap \
    && apt clean

RUN wget https://github.com/glpi-project/glpi/releases/download/10.0.14/glpi-10.0.14.tgz \
    && tar -xvzf glpi-10.0.14.tgz -C /var/www/html/ \
    && rm glpi-10.0.14.tgz

RUN chown -R www-data:www-data /var/www/html/glpi
RUN chown -R www-data:www-data /var/www/html/glpi/config

COPY config_db.php /var/www/html/glpi/config/config_db.php

COPY glpi.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]
