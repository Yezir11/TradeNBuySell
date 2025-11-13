#!/bin/bash

# TradeNBuySell Demo Setup Script
# This script sets up the database with comprehensive demo data

echo "=========================================="
echo "TradeNBuySell Demo Setup"
echo "=========================================="
echo ""

# Database configuration
DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

# Paths
SCHEMA_FILE="backend/src/main/resources/schema.sql"
MODERATION_SCHEMA_FILE="backend/src/main/resources/moderation_schema.sql"
SEED_DATA_FILE="backend/src/main/resources/seed_data.sql"

echo "Step 1: Creating database and schema..."
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${SCRIPT_DIR}"

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

echo "✅ Database schema created"
echo ""

echo "Step 2: Inserting seed data (users, ratings, trades, bids, etc.)..."
cd "${SCRIPT_DIR}"
mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${SCRIPT_DIR}/${SEED_DATA_FILE}

if [ $? -ne 0 ]; then
    echo "❌ Error inserting seed data"
    exit 1
fi

echo "✅ Seed data inserted"
echo ""

echo "Step 3: Inserting 209 listings from DemoArtifacts..."
cd "${SCRIPT_DIR}"
LISTINGS_209_FILE="scripts/209_listings_insert.sql"
if [ -f "${SCRIPT_DIR}/${LISTINGS_209_FILE}" ]; then
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ${SCRIPT_DIR}/${LISTINGS_209_FILE}
    
    if [ $? -ne 0 ]; then
        echo "❌ Error inserting 209 listings"
        exit 1
    fi
    
    echo "✅ 209 listings inserted"
else
    echo "⚠️  Warning: ${LISTINGS_209_FILE} not found. Run scripts/create-209-listings-from-demo-artifacts.py first"
    echo "✅ Continuing with existing listings from seed_data.sql"
fi
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
echo "Student Users:"
echo "  Email: student1@pilani.bits-pilani.ac.in"
echo "  Password: password123"
echo ""
echo "All users use password: password123"
echo ""
echo "Next Steps:"
echo "  1. Start the backend: cd backend && mvn spring-boot:run"
echo "  2. Start the frontend: cd frontend && npm start"
echo "  3. Start ML moderation service: cd ml-moderation && python api/app.py"
echo ""

