#!/bin/bash

# TradeNBuySell Demo Setup Script (Safe Version)
# This script checks for existing data before setting up

echo "=========================================="
echo "TradeNBuySell Demo Setup (Safe Mode)"
echo "=========================================="
echo ""

# Database configuration
DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA_FILE="backend/src/main/resources/schema.sql"
MODERATION_SCHEMA_FILE="backend/src/main/resources/moderation_schema.sql"
SEED_DATA_FILE="backend/src/main/resources/seed_data.sql"

echo "Step 1: Checking database status..."
cd "${SCRIPT_DIR}"

# Check if database exists
DB_EXISTS=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} -e "SHOW DATABASES LIKE '${DB_NAME}';" 2>/dev/null | grep -c "${DB_NAME}")

if [ "$DB_EXISTS" -eq 1 ]; then
    echo "✅ Database '${DB_NAME}' already exists"
    
    # Check if tables exist
    TABLE_COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$TABLE_COUNT" -gt 1 ]; then
        echo "⚠️  Database already has ${TABLE_COUNT} tables"
        
        # Check for existing data
        USER_COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) as count FROM users;" 2>/dev/null | tail -1 | tr -d ' ')
        
        if [ "$USER_COUNT" -gt 0 ]; then
            echo "⚠️  WARNING: Database already contains ${USER_COUNT} users!"
            echo ""
            read -p "Do you want to continue? This will TRUNCATE all existing data. (yes/no): " CONFIRM
            
            if [ "$CONFIRM" != "yes" ]; then
                echo "❌ Setup cancelled. Existing data preserved."
                exit 0
            fi
        fi
    fi
else
    echo "📝 Database '${DB_NAME}' does not exist. Will create it."
fi

echo ""
echo "Step 2: Creating/updating database schema..."
mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
USE ${DB_NAME};
SOURCE ${SCRIPT_DIR}/${SCHEMA_FILE};
SOURCE ${SCRIPT_DIR}/${MODERATION_SCHEMA_FILE};
EOF

if [ $? -ne 0 ]; then
    echo "❌ Error creating database schema"
    exit 1
fi

echo "✅ Database schema created/updated"
echo ""

echo "Step 3: Inserting seed data..."
mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${SCRIPT_DIR}/${SEED_DATA_FILE}

if [ $? -ne 0 ]; then
    echo "❌ Error inserting seed data"
    exit 1
fi

echo "✅ Seed data inserted"
echo ""

echo "Step 4: Verifying seed data..."
mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} << EOF
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Listings', COUNT(*) FROM listings
UNION ALL
SELECT 'Active Listings', COUNT(*) FROM listings WHERE is_active = 1
UNION ALL
SELECT 'Tradeable Listings', COUNT(*) FROM listings WHERE is_tradeable = 1
UNION ALL
SELECT 'Biddable Listings', COUNT(*) FROM listings WHERE is_biddable = 1
UNION ALL
SELECT 'Ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'Trades', COUNT(*) FROM trades
UNION ALL
SELECT 'Bids', COUNT(*) FROM bids
UNION ALL
SELECT 'Moderation Logs', COUNT(*) FROM moderation_logs;
EOF

echo ""
echo "=========================================="
echo "Demo Setup Complete!"
echo "=========================================="
echo ""
echo "Login Credentials:"
echo "  Email: admin@pilani.bits-pilani.ac.in"
echo "  Password: password123"
echo ""
echo "All users use password: password123"
echo ""

