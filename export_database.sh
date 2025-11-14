#!/bin/bash

DB_NAME="tradenbysell"
DB_USER="root"
DB_PASSWORD="root"
DB_HOST="localhost"
DB_PORT="3306"

OUTPUT_FILE="DATABASE_EXPORT.txt"

echo "================================================" > "$OUTPUT_FILE"
echo "TradeNBuySell Database Schema and Data Export" >> "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get all table names
TABLES=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" -s -N 2>/dev/null)

for TABLE in $TABLES; do
    echo "================================================" >> "$OUTPUT_FILE"
    echo "TABLE: $TABLE" >> "$OUTPUT_FILE"
    echo "================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get table structure
    echo "--- TABLE STRUCTURE ---" >> "$OUTPUT_FILE"
    mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "DESCRIBE $TABLE;" >> "$OUTPUT_FILE" 2>/dev/null
    echo "" >> "$OUTPUT_FILE"
    
    # Get row count
    COUNT=$(mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT COUNT(*) FROM $TABLE;" -s -N 2>/dev/null)
    echo "Total Rows: $COUNT" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Get all data
    if [ "$COUNT" -gt 0 ]; then
        echo "--- TABLE DATA ---" >> "$OUTPUT_FILE"
        mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT * FROM $TABLE;" >> "$OUTPUT_FILE" 2>/dev/null
    else
        echo "--- TABLE DATA ---" >> "$OUTPUT_FILE"
        echo "(No data)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "Export completed: $OUTPUT_FILE"
