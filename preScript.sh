#!/bin/bash

set -e

APP_DIR="/var/www/cicd-demo/backend"
BACKUP_ROOT="/var/www/cicd-demo/backend-deployment-backups"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_ROOT}/backend_${TIMESTAMP}"

echo "========================================"
echo "Starting pre-deployment backup"
echo "Application: ${APP_DIR}"
echo "Backup:      ${BACKUP_DIR}"
echo "========================================"

# Create backup directory
mkdir -p "$BACKUP_ROOT"

# Backup current application if it exists
if [ -d "$APP_DIR" ]; then

    echo "Backing up current application..."

    mkdir -p "$BACKUP_DIR"

    cp -a "$APP_DIR/." "$BACKUP_DIR/"

    echo "Backup completed:"
    echo "$BACKUP_DIR"

else

    echo "Application directory does not exist."
    echo "Skipping backup."

fi

# Keep only the latest 5 backups
echo "Cleaning old backups..."

ls -dt "${BACKUP_ROOT}"/backend_* 2>/dev/null \
    | tail -n +6 \
    | xargs -r rm -rf

echo "Pre-deployment step completed."