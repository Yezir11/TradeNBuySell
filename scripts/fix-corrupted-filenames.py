#!/usr/bin/env python3
"""
Fix corrupted filenames in database by matching with actual files.
The issue is encoding corruption: "â" became "aâ• Ã©" in the database.
"""

import os
import re
import subprocess
import sys
from collections import defaultdict

DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "tradenbysell"
UPLOAD_DIR = "backend/uploads"

def get_all_image_records():
    """Fetch all image records from database"""
    query = "SELECT image_id, listing_id, image_url FROM listing_images ORDER BY listing_id"
    
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '-e', query,
        '-s', '-N'
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        lines = result.stdout.strip().split('\n')
        
        records = []
        for line in lines:
            if not line.strip():
                continue
            parts = line.split('\t')
            if len(parts) >= 3:
                records.append({
                    'image_id': parts[0],
                    'listing_id': parts[1],
                    'image_url': parts[2]
                })
        return records
    except subprocess.CalledProcessError as e:
        print(f"Error querying database: {e.stderr}")
        sys.exit(1)

def get_actual_files_by_category():
    """Get all actual image files organized by category"""
    files_by_category = defaultdict(list)
    
    for category_dir in os.listdir(UPLOAD_DIR):
        category_path = os.path.join(UPLOAD_DIR, category_dir)
        if not os.path.isdir(category_path):
            continue
        
        for filename in os.listdir(category_path):
            if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
                files_by_category[category_dir].append(filename)
    
    return files_by_category

def extract_base_name(filename):
    """Extract base name pattern from filename"""
    # Remove extension
    name = os.path.splitext(filename)[0]
    
    # Extract pattern: prefix_number or prefix
    # e.g., "everyday_item_â_student_owned_8" -> ("everyday_item_â_student_owned", "8")
    match = re.match(r'(.+?)_(\d+)$', name)
    if match:
        return match.group(1), match.group(2)
    return name, None

def fix_corrupted_name(corrupted_name):
    """Try to fix corrupted filename patterns"""
    # Pattern: "everyday_item_aâ• Ã©_student_owned_8" -> "everyday_item_â_student_owned_8"
    # Replace "aâ• Ã©" with "â"
    fixed = re.sub(r'aâ•\s*Ã©', 'â', corrupted_name)
    # Also try other common corruptions
    fixed = re.sub(r'aâ•\s*Ã©', 'â', fixed)
    fixed = re.sub(r'a.*?student', 'â_student', fixed)
    return fixed

def find_matching_file(db_url, files_by_category):
    """Find matching file for a database URL"""
    # Extract category and filename from URL
    parts = db_url.split('/')
    if len(parts) < 4:
        return None
    
    category = parts[2]  # e.g., "used_Air_Coolers"
    db_filename = parts[3]  # e.g., "everyday_item_aâ• Ã©_student_owned_8.jpg"
    
    if category not in files_by_category:
        return None
    
    # Try to fix corrupted name
    fixed_name = fix_corrupted_name(db_filename)
    
    # Extract base pattern and number
    db_base, db_num = extract_base_name(fixed_name)
    db_ext = os.path.splitext(db_filename)[1]
    
    # Try exact match first (with fixed name)
    if fixed_name in files_by_category[category]:
        return os.path.join(category, fixed_name)
    
    # Try matching by base pattern and number
    for actual_filename in files_by_category[category]:
        actual_base, actual_num = extract_base_name(actual_filename)
        actual_ext = os.path.splitext(actual_filename)[1]
        
        # Match if base pattern is similar and number/ext match
        if actual_num == db_num and actual_ext == db_ext:
            # Check if base patterns are similar (allowing for encoding differences)
            db_base_clean = re.sub(r'[^a-z0-9_]', '', db_base.lower())
            actual_base_clean = re.sub(r'[^a-z0-9_]', '', actual_base.lower())
            
            # Remove the corrupted part and compare
            db_base_clean = re.sub(r'a.*?student', 'student', db_base_clean)
            actual_base_clean = re.sub(r'â', '', actual_base_clean)
            
            if db_base_clean == actual_base_clean or db_base_clean in actual_base_clean:
                return os.path.join(category, actual_filename)
    
    # Try fuzzy matching by number and extension only
    for actual_filename in files_by_category[category]:
        actual_base, actual_num = extract_base_name(actual_filename)
        actual_ext = os.path.splitext(actual_filename)[1]
        
        if actual_num == db_num and actual_ext == db_ext:
            # Check if it's a "student_owned" type file
            if 'student' in actual_base.lower() and 'student' in db_base.lower():
                return os.path.join(category, actual_filename)
    
    return None

def update_image_url(image_id, new_url):
    """Update image URL in database"""
    new_url = new_url.replace("'", "''")  # Escape single quotes
    
    query = f"UPDATE listing_images SET image_url = '/images/{new_url}' WHERE image_id = {image_id};"
    
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '-e', query
    ]
    
    try:
        subprocess.run(cmd, capture_output=True, text=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error updating image_id {image_id}: {e.stderr}")
        return False

def main():
    print("=" * 70)
    print("Fixing Corrupted Image Filenames")
    print("=" * 70)
    print()
    
    print("Step 1: Fetching image records from database...")
    db_records = get_all_image_records()
    print(f"Found {len(db_records)} image records")
    print()
    
    print("Step 2: Scanning actual files...")
    files_by_category = get_actual_files_by_category()
    total_files = sum(len(files) for files in files_by_category.values())
    print(f"Found {total_files} actual image files in {len(files_by_category)} categories")
    print()
    
    print("Step 3: Matching and fixing corrupted paths...")
    fixed_count = 0
    not_found_count = 0
    already_correct_count = 0
    
    for i, record in enumerate(db_records, 1):
        image_url = record['image_url']
        image_id = record['image_id']
        
        # Convert URL to expected file path
        if image_url.startswith('/images/'):
            relative_path = image_url[8:]  # Remove '/images/'
            expected_path = os.path.join(UPLOAD_DIR, relative_path)
            
            if os.path.exists(expected_path):
                already_correct_count += 1
            else:
                # Try to find matching file
                matching_file = find_matching_file(image_url, files_by_category)
                
                if matching_file:
                    if update_image_url(image_id, matching_file):
                        fixed_count += 1
                        if fixed_count <= 30:  # Show first 30 fixes
                            print(f"[{i}/{len(db_records)}] ✅ Fixed: {os.path.basename(image_url)} -> {os.path.basename(matching_file)}")
                    else:
                        not_found_count += 1
                else:
                    not_found_count += 1
                    if not_found_count <= 10:  # Show first 10 not found
                        print(f"[{i}/{len(db_records)}] ⚠️  Not found: {os.path.basename(image_url)}")
        
        if i % 50 == 0:
            print(f"Progress: {i}/{len(db_records)} (Fixed: {fixed_count}, Not found: {not_found_count})")
    
    print()
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print(f"✅ Already correct: {already_correct_count}")
    print(f"✅ Fixed: {fixed_count}")
    print(f"❌ Not found: {not_found_count}")
    print(f"📊 Total processed: {len(db_records)}")
    print()
    
    if not_found_count > 0:
        print("⚠️  Some images could not be matched.")
    else:
        print("✅ All image paths have been fixed!")
    print()

if __name__ == "__main__":
    main()

