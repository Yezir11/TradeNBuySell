#!/bin/bash

DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

OUTPUT_FILE="DATABASE_COMPLETE_DOCUMENTATION.txt"

# Start with header
cat > "$OUTPUT_FILE" << 'HEADER'
================================================================================
TradeNBuySell Database - Complete Schema and Data Documentation
================================================================================
Generated: $(date)
Database: tradenbysell

This document contains:
1. Complete database schema descriptions for all tables
2. All data currently stored in each table
3. Table relationships and constraints

================================================================================
HEADER

echo "" >> "$OUTPUT_FILE"
echo "TABLE OF CONTENTS" >> "$OUTPUT_FILE"
echo "=================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get all table names for TOC
TABLES=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" -s -N 2>/dev/null)
TABLE_NUM=1
for TABLE in $TABLES; do
    echo "$TABLE_NUM. $TABLE" >> "$OUTPUT_FILE"
    TABLE_NUM=$((TABLE_NUM + 1))
done

echo "" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Process each table
for TABLE in $TABLES; do
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "TABLE: $TABLE" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get CREATE TABLE statement
    echo "--- CREATE TABLE STATEMENT ---" >> "$OUTPUT_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW CREATE TABLE $TABLE\G" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    
    # Get table structure with detailed info
    echo "--- TABLE STRUCTURE (DESCRIBE) ---" >> "$OUTPUT_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "DESCRIBE $TABLE;" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    
    # Get indexes
    echo "--- INDEXES ---" >> "$OUTPUT_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW INDEXES FROM $TABLE;" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    
    # Get foreign keys
    echo "--- FOREIGN KEY CONSTRAINTS ---" >> "$OUTPUT_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DB_NAME}' AND TABLE_NAME = '${TABLE}' AND REFERENCED_TABLE_NAME IS NOT NULL;" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    
    # Get row count
    COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM $TABLE;" -s -N 2>/dev/null)
    echo "--- DATA COUNT ---" >> "$OUTPUT_FILE"
    echo "Total Rows: $COUNT" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get all data
    if [ "$COUNT" -gt 0 ]; then
        echo "--- ALL TABLE DATA ---" >> "$OUTPUT_FILE"
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT * FROM $TABLE;" >> "$OUTPUT_FILE" 2>/dev/null
    else
        echo "--- ALL TABLE DATA ---" >> "$OUTPUT_FILE"
        echo "(No data in this table)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "Comprehensive database documentation created: $OUTPUT_FILE"
