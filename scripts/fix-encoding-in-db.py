#!/usr/bin/env python3
"""
Fix encoding in database by replacing corrupted characters with correct ones.
The database has "" (replacement char) but files have "â".
"""

import subprocess
import sys

DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "tradenbysell"

def update_encoding():
    """Update image URLs to fix encoding issues"""
    
    # Update all URLs that have the corrupted pattern
    # Replace patterns like "everyday_item__student_owned" with "everyday_item_â_student_owned"
    
    queries = [
        # Fix double underscore patterns (where â was lost)
        "UPDATE listing_images SET image_url = REPLACE(image_url, 'everyday_item__student_owned', 'everyday_item_â_student_owned') WHERE image_url LIKE '%everyday_item__student_owned%';",
        "UPDATE listing_images SET image_url = REPLACE(image_url, 'useful_item__student_owned', 'useful_item_â_student_owned') WHERE image_url LIKE '%useful_item__student_owned%';",
        "UPDATE listing_images SET image_url = REPLACE(image_url, 'campus_essential__student_owned', 'campus_essential_â_student_owned') WHERE image_url LIKE '%campus_essential__student_owned%';",
        
        # Also fix any remaining corrupted patterns
        "UPDATE listing_images SET image_url = REPLACE(image_url, 'aâ• Ã©', 'â') WHERE image_url LIKE '%aâ•%';",
    ]
    
    print("=" * 70)
    print("Fixing Encoding in Database")
    print("=" * 70)
    print()
    
    for i, query in enumerate(queries, 1):
        print(f"Step {i}: Running update query...")
        cmd = [
            'mysql',
            f'-h{DB_HOST}',
            f'-P{DB_PORT}',
            f'-u{DB_USER}',
            f'-p{DB_PASSWORD}',
            DB_NAME,
            '--default-character-set=utf8mb4',
            '-e', query
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            # Check affected rows from output
            if 'Rows matched' in result.stdout or result.returncode == 0:
                print(f"  ✅ Query {i} executed successfully")
            else:
                print(f"  ⚠️  Query {i} completed (check output)")
        except subprocess.CalledProcessError as e:
            print(f"  ❌ Error in query {i}: {e.stderr}")
    
    print()
    print("Step 5: Verifying updates...")
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '--default-character-set=utf8mb4',
        '-e', "SELECT COUNT(*) as fixed_count FROM listing_images WHERE image_url LIKE '%â_student_owned%';"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"  Found URLs with 'â': {result.stdout.strip()}")
    except:
        pass
    
    print()
    print("=" * 70)
    print("✅ Encoding fix complete!")
    print("=" * 70)
    print()

if __name__ == "__main__":
    update_encoding()

