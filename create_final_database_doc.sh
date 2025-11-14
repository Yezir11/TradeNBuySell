#!/bin/bash

DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

OUTPUT_FILE="DATABASE_COMPLETE_DOCUMENTATION.txt"

# Create comprehensive documentation
{
cat << 'HEADER'
================================================================================
TradeNBuySell Database - Complete Schema and Data Documentation
================================================================================
Generated: $(date)
Database: tradenbysell

This document contains:
1. Complete database schema (CREATE TABLE statements from schema.sql)
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

SECTION 1: COMPLETE DATABASE SCHEMA
====================================

The following section contains the complete SQL schema definitions for all tables.

HEADER

echo ""
echo "--- Main Schema (schema.sql) ---"
echo ""
cat backend/src/main/resources/schema.sql

echo ""
echo ""
echo "--- Moderation Schema (moderation_schema.sql) ---"
echo ""
cat backend/src/main/resources/moderation_schema.sql

cat << 'SECTION2'

================================================================================

SECTION 2: CURRENT DATABASE STATE
==================================

This section shows the current state of each table including structure,
indexes, constraints, and all data.

SECTION2

echo ""

# Get all table names
TABLES=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" -s -N 2>/dev/null)

echo "TABLE OF CONTENTS"
echo "================="
echo ""
TABLE_NUM=1
for TABLE in $TABLES; do
    echo "$TABLE_NUM. $TABLE"
    TABLE_NUM=$((TABLE_NUM + 1))
done

echo ""
echo "================================================================================"
echo ""

# Process each table
for TABLE in $TABLES; do
    echo "================================================================================"
    echo "TABLE: $TABLE"
    echo "================================================================================"
    echo ""
    
    # Get table structure
    echo "--- TABLE STRUCTURE (DESCRIBE) ---"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "DESCRIBE $TABLE;" 2>/dev/null
    echo ""
    
    # Get indexes
    echo "--- INDEXES ---"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW INDEXES FROM $TABLE;" 2>/dev/null
    echo ""
    
    # Get foreign keys
    echo "--- FOREIGN KEY CONSTRAINTS ---"
    FK_COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DB_NAME}' AND TABLE_NAME = '${TABLE}' AND REFERENCED_TABLE_NAME IS NOT NULL;" -s -N 2>/dev/null)
    if [ "$FK_COUNT" -gt 0 ]; then
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = '${DB_NAME}' AND TABLE_NAME = '${TABLE}' AND REFERENCED_TABLE_NAME IS NOT NULL;" 2>/dev/null
    else
        echo "(No foreign key constraints)"
    fi
    echo ""
    
    # Get row count
    COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM $TABLE;" -s -N 2>/dev/null)
    echo "--- DATA COUNT ---"
    echo "Total Rows: $COUNT"
    echo ""
    
    # Get all data
    if [ "$COUNT" -gt 0 ]; then
        echo "--- ALL TABLE DATA ---"
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT * FROM $TABLE;" 2>/dev/null
    else
        echo "--- ALL TABLE DATA ---"
        echo "(No data in this table)"
    fi
    echo ""
    echo ""
done

} | sed "s/Generated: \$(date)/Generated: $(date)/" > "$OUTPUT_FILE"

echo "Complete database documentation created: $OUTPUT_FILE"
