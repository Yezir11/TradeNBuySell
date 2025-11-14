#!/usr/bin/env python3
import re
from datetime import datetime

# Read the existing documentation
with open('DATABASE_COMPLETE_DOCUMENTATION.txt', 'r') as f:
    content = f.read()

# Read schema files for detailed descriptions
schema_descriptions = {}

# Read main schema
with open('backend/src/main/resources/schema.sql', 'r') as f:
    schema_sql = f.read()
    
# Extract table descriptions from comments
table_descriptions = {}
for line in schema_sql.split('\n'):
    if '--' in line and 'Table' in line:
        match = re.search(r'--\s*(\w+)\s+Table', line)
        if match:
            table_name = match.group(1).lower()
            desc = line.replace('--', '').strip()
            table_descriptions[table_name] = desc

# Read moderation schema
with open('backend/src/main/resources/moderation_schema.sql', 'r') as f:
    mod_schema = f.read()
    if 'moderation_logs' in mod_schema:
        table_descriptions['moderation_logs'] = 'Moderation Logs Table for ML-based content moderation'

# Create enhanced header
enhanced_header = f"""================================================================================
TradeNBuySell Database - Complete Schema and Data Documentation
================================================================================
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
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

"""

# Write enhanced documentation
with open('DATABASE_COMPLETE_DOCUMENTATION.txt', 'w') as f:
    f.write(enhanced_header)
    f.write(content)

print("Enhanced database documentation created successfully!")
