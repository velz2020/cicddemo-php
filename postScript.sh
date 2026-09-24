#!/bin/bash

set -e

APP_DIR="/var/www/cicd-demo/backend"

echo "========================================"
echo "Starting post-deployment configuration"
echo "Application: ${APP_DIR}"
echo "========================================"

cd "$APP_DIR"

echo "========================================"
echo "DEPLOYMENT VERIFICATION"
echo "========================================"

echo "Deployment directory:"
pwd

echo "Directory contents:"
ls -lah

echo "Build information:"
if [ -f "build-info.txt" ]; then
    cat build-info.txt
else
    echo "ERROR: build-info.txt NOT FOUND"
fi

echo "========================================"

# --------------------------------------------------
# CodeIgniter writable permissions
# --------------------------------------------------

echo "Setting writable permissions..."

if [ -d "writable" ]; then
    chown -R www-data:www-data writable
    chmod -R 775 writable
fi

# --------------------------------------------------
# Application ownership
# --------------------------------------------------

echo "Setting application ownership..."

chown -R www-data:www-data "$APP_DIR"

# --------------------------------------------------
# Nginx configuration test
# --------------------------------------------------

echo "Testing Nginx configuration..."

nginx -t

# --------------------------------------------------
# Reload Nginx
# --------------------------------------------------

echo "Reloading Nginx..."

systemctl reload nginx

# --------------------------------------------------
# PHP-FPM
# --------------------------------------------------

echo "Checking PHP-FPM service..."

PHP_FPM_SERVICE=$(systemctl list-units \
    --type=service \
    --all \
    --no-legend \
    | awk '$1 ~ /^php.*-fpm\.service$/ {print $1; exit}')

if [ -n "$PHP_FPM_SERVICE" ]; then

    echo "Found PHP-FPM service: $PHP_FPM_SERVICE"

    systemctl restart "$PHP_FPM_SERVICE"

else

    echo "PHP-FPM service not found."
    echo "Skipping PHP-FPM restart."

fi

echo "========================================"
echo "Deployment completed successfully."
echo "========================================"