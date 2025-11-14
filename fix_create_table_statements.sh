#!/bin/bash

DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

TEMP_FILE="temp_doc.txt"
FINAL_FILE="DATABASE_COMPLETE_DOCUMENTATION.txt"

# Create new file with proper CREATE TABLE statements
cat > "$TEMP_FILE" << 'HEADER'
================================================================================
TradeNBuySell Database - Complete Schema and Data Documentation
================================================================================
Generated: $(date)
Database: tradenbysell

This document contains:
1. Complete database schema descriptions for all tables
2. Table structure with field descriptions
3. Indexes and foreign key constraints
4. All data currently stored in each table
5. Table relationships

================================================================================

DATABASE OVERVIEW
=================

The TradeNBuySell database is designed for a peer-to-peer trading platform
for BITS Pilani students. It supports:
- User management with trust scores
- Listings (buy, trade, and bid)
- Trading system with multiple offerings
- Bidding/auction system
- Wallet transactions
- Ratings and reviews
- Chat messaging
- Content moderation (ML-based)
- Reports and feedback

================================================================================

HEADER

# Get all table names
TABLES=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" -s -N 2>/dev/null)

echo "" >> "$TEMP_FILE"
echo "TABLE OF CONTENTS" >> "$TEMP_FILE"
echo "=================" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

TABLE_NUM=1
for TABLE in $TABLES; do
    echo "$TABLE_NUM. $TABLE" >> "$TEMP_FILE"
    TABLE_NUM=$((TABLE_NUM + 1))
done

echo "" >> "$TEMP_FILE"
echo "================================================================================" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Process each table
for TABLE in $TABLES; do
    echo "================================================================================" >> "$TEMP_FILE"
    echo "TABLE: $TABLE" >> "$TEMP_FILE"
    echo "================================================================================" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    # Get CREATE TABLE statement
    echo "--- CREATE TABLE STATEMENT ---" >> "$TEMP_FILE"
    CREATE_STMT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW CREATE TABLE $TABLE\G" 2>/dev/null | grep -A 100 "Create Table" | tail -n +2)
    echo "$CREATE_STMT" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    # Get table structure
    echo "--- TABLE STRUCTURE (DESCRIBE) ---" >> "$TEMP_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "DESCRIBE $TABLE;" >> "$TEMP_FILE" 2>/dev/null
    echo "" >> "$TEMP_FILE"
    
    # Get indexes
    echo "--- INDEXES ---" >> "$TEMP_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW INDEXES FROM $TABLE;" >> "$TEMP_FILE" 2>/dev/null
    echo "" >> "$TEMP_FILE"
    
    # Get foreign keys
    echo "--- FOREIGN KEY CONSTRAINTS ---" >> "$TEMP_FILE"
    FK_COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DB_NAME}' AND TABLE_NAME = '${TABLE}' AND REFERENCED_TABLE_NAME IS NOT NULL;" -s -N 2>/dev/null)
    if [ "$FK_COUNT" -gt 0 ]; then
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DB_NAME}' AND TABLE_NAME = '${TABLE}' AND REFERENCED_TABLE_NAME IS NOT NULL;" >> "$TEMP_FILE" 2>/dev/null
    else
        echo "(No foreign key constraints)" >> "$TEMP_FILE"
    fi
    echo "" >> "$TEMP_FILE"
    
    # Get row count
    COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM $TABLE;" -s -N 2>/dev/null)
    echo "--- DATA COUNT ---" >> "$TEMP_FILE"
    echo "Total Rows: $COUNT" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    
    # Get all data
    if [ "$COUNT" -gt 0 ]; then
        echo "--- ALL TABLE DATA ---" >> "$TEMP_FILE"
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT * FROM $TABLE;" >> "$TEMP_FILE" 2>/dev/null
    else
        echo "--- ALL TABLE DATA ---" >> "$TEMP_FILE"
        echo "(No data in this table)" >> "$TEMP_FILE"
    fi
    echo "" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
done

# Replace date placeholder
sed "s/Generated: \$(date)/Generated: $(date)/" "$TEMP_FILE" > "$FINAL_FILE"
rm "$TEMP_FILE"

echo "Complete database documentation created: $FINAL_FILE"
