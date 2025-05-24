#!/bin/bash
# Entrypoint para instalar dependencias y arrancar Apache

echo "Instalando dependencias de GLPI..."
php bin/console dependencies install || true

# Iniciar Apache en primer plano
exec apache2-foreground
