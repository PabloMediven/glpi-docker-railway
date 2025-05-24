#!/bin/bash
# Entrypoint para instalar dependencias y arrancar Apache

echo "Instalando dependencias de GLPI..."

cd /var/www/glpi
php bin/console dependencies install || true

# Volver al directorio raíz por si acaso
cd /var/www

# Iniciar Apache en primer plano
exec apache2-foreground
