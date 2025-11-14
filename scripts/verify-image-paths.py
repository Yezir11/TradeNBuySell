#!/usr/bin/env python3
"""
Verify that all image paths in the database correspond to actual files.
"""

import os
import subprocess
import sys

DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "tradenbysell"
UPLOAD_DIR = "backend/uploads"

def get_image_paths():
    """Fetch all image URLs from database"""
    query = "SELECT listing_id, image_url FROM listing_images ORDER BY listing_id"
    
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '-e', query,
        '-s',  # silent mode
        '-N'   # skip column names
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        lines = result.stdout.strip().split('\n')
        
        image_paths = []
        for line in lines:
            if not line.strip():
                continue
            parts = line.split('\t')
            if len(parts) >= 2:
                image_paths.append({
                    'listing_id': parts[0],
                    'image_url': parts[1]
                })
        return image_paths
    except subprocess.CalledProcessError as e:
        print(f"Error querying database: {e.stderr}")
        sys.exit(1)

def convert_url_to_filepath(image_url):
    """Convert database URL to actual file path"""
    # Remove leading /images/
    if image_url.startswith('/images/'):
        relative_path = image_url[8:]  # Remove '/images/'
        return os.path.join(UPLOAD_DIR, relative_path)
    return None

def main():
    print("=" * 70)
    print("Verifying Image Paths")
    print("=" * 70)
    print()
    
    print("Step 1: Fetching image URLs from database...")
    image_paths = get_image_paths()
    print(f"Found {len(image_paths)} image records")
    print()
    
    print("Step 2: Verifying files exist...")
    missing_files = []
    existing_files = []
    invalid_paths = []
    
    for img in image_paths:
        filepath = convert_url_to_filepath(img['image_url'])
        
        if not filepath:
            invalid_paths.append(img)
            continue
        
        if os.path.exists(filepath):
            existing_files.append(img)
        else:
            missing_files.append({
                'listing_id': img['listing_id'],
                'image_url': img['image_url'],
                'expected_path': filepath
            })
    
    print()
    print("=" * 70)
    print("Results")
    print("=" * 70)
    print(f"✅ Files found: {len(existing_files)}")
    print(f"❌ Files missing: {len(missing_files)}")
    print(f"⚠️  Invalid paths: {len(invalid_paths)}")
    print()
    
    if missing_files:
        print("Missing Files (first 20):")
        print("-" * 70)
        for i, missing in enumerate(missing_files[:20], 1):
            print(f"{i}. Listing: {missing['listing_id'][:8]}...")
            print(f"   URL: {missing['image_url']}")
            print(f"   Expected: {missing['expected_path']}")
            print()
        
        if len(missing_files) > 20:
            print(f"... and {len(missing_files) - 20} more missing files")
        print()
    
    if invalid_paths:
        print("Invalid Paths (first 10):")
        print("-" * 70)
        for i, invalid in enumerate(invalid_paths[:10], 1):
            print(f"{i}. Listing: {invalid['listing_id'][:8]}...")
            print(f"   URL: {invalid['image_url']}")
            print()
    
    # Check for similar filenames
    print("Step 3: Checking for similar filenames...")
    if missing_files:
        print("\nChecking if files exist with similar names...")
        for missing in missing_files[:10]:
            expected_dir = os.path.dirname(missing['expected_path'])
            expected_filename = os.path.basename(missing['expected_path'])
            
            if os.path.exists(expected_dir):
                files_in_dir = os.listdir(expected_dir)
                # Check for files with similar names
                similar = [f for f in files_in_dir if expected_filename.lower() in f.lower() or f.lower() in expected_filename.lower()]
                if similar:
                    print(f"\nListing {missing['listing_id'][:8]}...")
                    print(f"  Expected: {expected_filename}")
                    print(f"  Found similar: {', '.join(similar[:3])}")
    
    print()
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    if missing_files:
        print(f"⚠️  {len(missing_files)} image files are missing from the file system")
        print("   These listings will not display images correctly.")
    else:
        print("✅ All image files exist!")
    print()

if __name__ == "__main__":
    main()

