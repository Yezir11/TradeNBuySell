#!/bin/bash

# Backup Current Database Data
# This script exports all data from the current database before running demo_tradenbuyseed_v3.sql

# Database configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-root}"
DB_NAME="${DB_NAME:-tradenbysell}"

# Backup directory
BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/database_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

echo "=========================================="
echo "Backing up current database data..."
echo "=========================================="
echo ""

# Export all data (no schema, data only)
echo "Step 1: Exporting users table..."
mysqldump -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} \
  --no-create-info --skip-triggers --skip-add-locks \
  ${DB_NAME} users >> "${BACKUP_FILE}" 2>/dev/null

if [ $? -ne 0 ]; then
  echo "❌ Error backing up users table"
  exit 1
fi

echo "Step 2: Exporting listings and related data..."
mysqldump -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} \
  --no-create-info --skip-triggers --skip-add-locks \
  ${DB_NAME} listings listing_images listing_tags bids trades trade_offerings \
  ratings chat_messages wishlists wallet_transactions transaction_history \
  moderation_logs feedbacks reports >> "${BACKUP_FILE}" 2>/dev/null

if [ $? -ne 0 ]; then
  echo "❌ Error backing up listings and related data"
  exit 1
fi

echo ""
echo "✅ Backup completed successfully!"
echo "📁 Backup file: ${BACKUP_FILE}"
echo ""
echo "To restore this backup, run:"
echo "  mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${BACKUP_FILE}"
echo ""

