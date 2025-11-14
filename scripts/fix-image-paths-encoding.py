#!/usr/bin/env python3
"""
Fix image path encoding issues in the database.
Matches database URLs with actual files in the uploads directory.
"""

import os
import re
import subprocess
import sys
from pathlib import Path

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

def get_actual_files():
    """Get all actual image files in uploads directory"""
    actual_files = {}
    
    for category_dir in os.listdir(UPLOAD_DIR):
        category_path = os.path.join(UPLOAD_DIR, category_dir)
        if not os.path.isdir(category_path):
            continue
        
        for filename in os.listdir(category_path):
            if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
                # Store with normalized name (lowercase, no special chars)
                normalized = filename.lower().replace('_', '').replace('-', '').replace(' ', '')
                actual_files[normalized] = {
                    'category': category_dir,
                    'filename': filename,
                    'full_path': os.path.join(category_dir, filename)
                }
    
    return actual_files

def normalize_filename(filename):
    """Normalize filename for matching"""
    # Remove extension
    name = os.path.splitext(filename)[0]
    # Convert to lowercase, remove special chars
    name = re.sub(r'[^a-z0-9]', '', name.lower())
    return name

def find_matching_file(db_url, actual_files):
    """Find matching file for a database URL"""
    # Extract filename from URL
    url_filename = os.path.basename(db_url)
    url_category = db_url.split('/')[2] if len(db_url.split('/')) > 2 else None
    
    # Try exact match first
    if url_category:
        category_path = os.path.join(UPLOAD_DIR, url_category)
        if os.path.exists(category_path):
            expected_path = os.path.join(category_path, url_filename)
            if os.path.exists(expected_path):
                return os.path.join(url_category, url_filename)
    
    # Try normalized matching
    normalized_db = normalize_filename(url_filename)
    
    for normalized, file_info in actual_files.items():
        normalized_file = normalize_filename(file_info['filename'])
        
        # Check if they match (allowing for some variation)
        if normalized_db == normalized_file or normalized_db in normalized_file or normalized_file in normalized_db:
            # Also check category matches if available
            if url_category and file_info['category'] == url_category:
                return file_info['full_path']
            elif not url_category:
                return file_info['full_path']
    
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
    print("Fixing Image Path Encoding Issues")
    print("=" * 70)
    print()
    
    print("Step 1: Fetching image records from database...")
    db_records = get_all_image_records()
    print(f"Found {len(db_records)} image records")
    print()
    
    print("Step 2: Scanning actual files in uploads directory...")
    actual_files = get_actual_files()
    print(f"Found {len(actual_files)} actual image files")
    print()
    
    print("Step 3: Matching and fixing paths...")
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
                if i % 50 == 0:
                    print(f"[{i}/{len(db_records)}] Already correct: {relative_path}")
            else:
                # Try to find matching file
                matching_file = find_matching_file(image_url, actual_files)
                
                if matching_file:
                    if update_image_url(image_id, matching_file):
                        fixed_count += 1
                        print(f"[{i}/{len(db_records)}] ✅ Fixed: {os.path.basename(image_url)} -> {matching_file}")
                    else:
                        not_found_count += 1
                        print(f"[{i}/{len(db_records)}] ❌ Update failed: {os.path.basename(image_url)}")
                else:
                    not_found_count += 1
                    if not_found_count <= 20:  # Show first 20 not found
                        print(f"[{i}/{len(db_records)}] ⚠️  Not found: {os.path.basename(image_url)}")
        else:
            not_found_count += 1
    
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
        print("⚠️  Some images could not be matched. These listings will not display images.")
        print("   You may need to manually check these files or re-upload the images.")
    print()

if __name__ == "__main__":
    main()

