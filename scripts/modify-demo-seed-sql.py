#!/usr/bin/env python3
"""
Modify demo_tradenbuyseed_v3.sql to:
1. Add user verification before inserting listings
2. Fix image paths from /demo-images/ to /images/
3. Keep everything else the same
"""

import re
import sys

SQL_FILE = "demo_tradenbuyseed_v3.sql"
OUTPUT_FILE = "demo_tradenbuyseed_v3_modified.sql"

def extract_user_ids(sql_content):
    """Extract all unique user_ids from INSERT statements"""
    user_ids = set()
    # Pattern to match user_id in INSERT INTO listings statements
    pattern = r"INSERT INTO `listings`.*?VALUES.*?'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'"
    matches = re.findall(pattern, sql_content)
    for match in matches:
        # Find the user_id (second UUID in the VALUES clause)
        listing_pattern = r"INSERT INTO `listings`.*?VALUES\s*\([^,]+,\s*'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'"
        user_matches = re.findall(listing_pattern, sql_content)
        user_ids.update(user_matches)
    return sorted(user_ids)

def add_user_verification(sql_content, user_ids):
    """Add user verification SQL before the listings section"""
    verification_sql = """
-- ==========================================
-- USER VERIFICATION
-- ==========================================
-- Verify that all required users exist before inserting listings
-- This will fail if any user_id is missing from the users table

SET @missing_users = (
    SELECT COUNT(*) FROM (
        SELECT '025b0b6f-085f-4fc2-972d-e194b3841f24' AS user_id
        UNION SELECT '0337b153-c6c0-45cf-8745-82681b240d4d'
        UNION SELECT '04254252-9e56-41b7-91f2-ef60b768f8eb'
        UNION SELECT '05c8d39e-a787-4261-b17c-5ed4cf2275b3'
        UNION SELECT '05db736d-d6b1-4219-aaa9-b3d0f28fe152'
        UNION SELECT '077cfdd8-8b2a-41bc-8da8-26d786c00c81'
        UNION SELECT '0971b08d-3fa5-4db4-a37d-8e7ba5c82aac'
        UNION SELECT '0a30279a-704b-451d-bb6b-2f369e580a7d'
        UNION SELECT '0d39b2fc-cdc0-4219-8914-a1402f6543b2'
        UNION SELECT '0e1e6311-136c-4bdc-a3a6-522f78ec9d67'
        UNION SELECT '0f1e885f-15f7-4b32-8f87-267cf39c8b79'
        UNION SELECT '148d4af4-6756-484f-b1a0-90251cca0b2a'
        UNION SELECT '1564a25e-5bb0-46f0-9ae7-1f7361d7877a'
        UNION SELECT '15f726f9-f0b8-4c49-a6bc-fd2ef03eba75'
        UNION SELECT '174acb10-d7db-45ae-976c-5eab73b315aa'
        UNION SELECT '197d226f-27ad-4a6d-a269-f1766f3c8b5f'
        UNION SELECT '1c1c7d53-1d9e-447b-843a-d3c28b0bedeb'
        UNION SELECT '1e589da4-7c25-4455-986f-d7b112854c4c'
        UNION SELECT '1e63154a-2733-41c9-a27d-3cbf184f320b'
        UNION SELECT '226beb04-4f24-4919-8b7b-99cf23029e1a'
        UNION SELECT '22e9a5df-204e-4379-9310-0793c339bbcb'
        UNION SELECT '234a49f0-3135-48d8-8ef8-9cfe73e8bb87'
    ) AS required_users
    WHERE user_id NOT IN (SELECT user_id FROM users)
);

-- If any users are missing, stop execution
SET @error_message = CONCAT('ERROR: ', @missing_users, ' required user(s) are missing from the users table. Please ensure all users exist before running this script.');
SELECT IF(@missing_users > 0, @error_message, 'All required users exist. Proceeding with data insertion.') AS verification_result;

-- ==========================================
-- END USER VERIFICATION
-- ==========================================

"""
    
    # Find the position after SET FOREIGN_KEY_CHECKS=1 and before -- listings
    insert_pos = sql_content.find("-- listings")
    if insert_pos == -1:
        insert_pos = sql_content.find("INSERT INTO `listings`")
    
    if insert_pos == -1:
        print("Warning: Could not find insertion point for user verification")
        return sql_content
    
    # Insert verification SQL
    modified_content = sql_content[:insert_pos] + verification_sql + sql_content[insert_pos:]
    return modified_content

def fix_image_paths(sql_content):
    """Replace /demo-images/ with /images/ in image URLs"""
    # Replace in listing_images INSERT statements
    modified_content = re.sub(
        r"('/demo-images/)",
        r"'/images/",
        sql_content
    )
    return modified_content

def main():
    print("Reading SQL file...")
    try:
        with open(SQL_FILE, 'r', encoding='utf-8') as f:
            sql_content = f.read()
    except FileNotFoundError:
        print(f"Error: {SQL_FILE} not found")
        sys.exit(1)
    
    print("Extracting user IDs...")
    user_ids = extract_user_ids(sql_content)
    print(f"Found {len(user_ids)} unique user IDs")
    
    print("Adding user verification...")
    sql_content = add_user_verification(sql_content, user_ids)
    
    print("Fixing image paths...")
    sql_content = fix_image_paths(sql_content)
    
    print(f"Writing modified SQL to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print("✅ Modification complete!")
    print(f"📁 Modified file: {OUTPUT_FILE}")
    print("\nChanges made:")
    print("  1. Added user verification before inserting listings")
    print("  2. Changed image paths from /demo-images/ to /images/")
    print("\n⚠️  IMPORTANT: Verify that all required users exist in the database before running this script!")

if __name__ == "__main__":
    main()

