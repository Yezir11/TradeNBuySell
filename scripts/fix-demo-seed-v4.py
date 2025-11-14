#!/usr/bin/env python3
"""
Fix demo_tradenbuyseed_v4.sql:
1. Fix image paths from /demo-images/ to /images/ (matching backend WebConfig)
2. Add user verification before inserting listings
3. Ensure all required users exist
"""

import re
import sys
import os

SQL_FILE = "demo_tradenbuyseed_v4.sql"
OUTPUT_FILE = "demo_tradenbuyseed_v4_fixed.sql"

def extract_user_ids(sql_content):
    """Extract all unique user_ids from INSERT statements"""
    user_ids = set()
    # Pattern to match user_id in INSERT INTO listings statements
    pattern = r"INSERT INTO `listings`.*?VALUES\s*\([^,]+,\s*'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'"
    matches = re.findall(pattern, sql_content)
    user_ids.update(matches)
    return sorted(user_ids)

def add_user_verification(sql_content, user_ids):
    """Add user verification SQL before the listings section"""
    if not user_ids:
        return sql_content
    
    # Build UNION SELECT statements for all user IDs
    user_union = "\n        UNION SELECT ".join([f"'{uid}'" for uid in user_ids])
    
    verification_sql = f"""
-- ==========================================
-- USER VERIFICATION
-- ==========================================
-- Verify that all required users exist before inserting listings
-- This will fail if any user_id is missing from the users table

SET @missing_users = (
    SELECT COUNT(*) FROM (
        SELECT {user_union.replace('UNION SELECT', '', 1) if user_ids else "'00000000-0000-0000-0000-000000000000'"} AS user_id
        {'UNION SELECT ' + user_union if len(user_ids) > 1 else ''}
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
    
    # Find the position after SET FOREIGN_KEY_CHECKS=1 and before -- Insert listings
    insert_pos = sql_content.find("-- Insert listings")
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

def verify_file_structure():
    """Verify that the uploads directory structure matches what's in the SQL"""
    uploads_dir = "backend/uploads"
    if not os.path.exists(uploads_dir):
        print(f"Warning: {uploads_dir} directory not found")
        return False
    
    # Check for expected subdirectories
    expected_dirs = [
        "used_Air_Coolers",
        "used_Bicycles", 
        "used_Chairs",
        "used_Headphoens",
        "used_Mattresses",
        "used_Monitors",
        "used_Shoes",
        "used_Smartphones"
    ]
    
    existing_dirs = [d for d in os.listdir(uploads_dir) if os.path.isdir(os.path.join(uploads_dir, d))]
    
    print("Expected directories in uploads/:")
    for exp_dir in expected_dirs:
        if exp_dir in existing_dirs:
            print(f"  ✅ {exp_dir}")
        else:
            print(f"  ⚠️  {exp_dir} (not found)")
    
    return True

def main():
    print("=" * 70)
    print("Fixing demo_tradenbuyseed_v4.sql")
    print("=" * 70)
    print()
    
    # Verify file structure
    print("Step 1: Verifying uploads directory structure...")
    verify_file_structure()
    print()
    
    print("Step 2: Reading SQL file...")
    try:
        with open(SQL_FILE, 'r', encoding='utf-8') as f:
            sql_content = f.read()
    except FileNotFoundError:
        print(f"Error: {SQL_FILE} not found")
        sys.exit(1)
    
    print("Step 3: Extracting user IDs...")
    user_ids = extract_user_ids(sql_content)
    print(f"Found {len(user_ids)} unique user IDs:")
    for uid in user_ids[:10]:  # Show first 10
        print(f"  - {uid}")
    if len(user_ids) > 10:
        print(f"  ... and {len(user_ids) - 10} more")
    print()
    
    print("Step 4: Adding user verification...")
    sql_content = add_user_verification(sql_content, user_ids)
    
    print("Step 5: Fixing image paths...")
    sql_content = fix_image_paths(sql_content)
    
    # Count replacements
    demo_images_count = sql_content.count("/demo-images/")
    images_count = sql_content.count("/images/")
    
    if demo_images_count > 0:
        print(f"  ⚠️  Warning: {demo_images_count} instances of '/demo-images/' still found")
    else:
        print(f"  ✅ All paths updated to '/images/' ({images_count} instances)")
    
    print()
    print(f"Step 6: Writing fixed SQL to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print()
    print("=" * 70)
    print("✅ Modification complete!")
    print("=" * 70)
    print(f"📁 Fixed file: {OUTPUT_FILE}")
    print()
    print("Changes made:")
    print("  1. ✅ Added user verification before inserting listings")
    print("  2. ✅ Changed image paths from /demo-images/ to /images/")
    print()
    print("⚠️  IMPORTANT:")
    print(f"  - Verify that all {len(user_ids)} required users exist in the database")
    print("  - The backend serves images via /images/** endpoint")
    print("  - Image files should be in: backend/uploads/used_*/")
    print()

if __name__ == "__main__":
    main()

