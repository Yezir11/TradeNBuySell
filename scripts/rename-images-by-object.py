#!/usr/bin/env python3
"""
Rename image files according to the object in the image (based on listing title).
This script:
1. Reads listing data from the database
2. Extracts the current image filename from image_url
3. Creates a new filename based on the listing title
4. Renames the physical file
5. Updates the database with the new image_url
"""

import os
import re
import sys
import subprocess
from pathlib import Path

# Configuration
DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "tradenbysell"
UPLOAD_DIR = "backend/uploads"

def extract_object_name(title):
    """Extract the actual object name from listing title"""
    # Remove common prefixes/suffixes
    title = title.lower()
    
    # Remove common prefixes
    prefixes = [
        r'^used\s+',
        r'^pre-owned\s+',
        r'^everyday\s+item\s+',
        r'^useful\s+item\s+',
        r'^campus\s+essential\s+',
        r'^student\s+owned\s*',
        r'^for\s+sale\s*$',
        r'^in\s+good\s+condition\s*$',
        r'^from\s+campus\s*$',
        r'\s*—\s*student\s+owned\s*$',
        r'\s*—\s*$',
    ]
    
    for prefix in prefixes:
        title = re.sub(prefix, '', title, flags=re.IGNORECASE)
    
    # Extract key words (nouns that describe the object)
    # Look for specific product names
    product_keywords = [
        r'\b(monitor|screen|display)\b',
        r'\b(bicycle|bike|cycle)\b',
        r'\b(mattress|bed)\b',
        r'\b(chair|sofa|couch)\b',
        r'\b(table|desk)\b',
        r'\b(headphone|earphone)\b',
        r'\b(phone|smartphone|mobile)\b',
        r'\b(cooler|air\s+cooler)\b',
        r'\b(sneaker|shoe)\b',
        r'\b(backpack|bag)\b',
    ]
    
    for pattern in product_keywords:
        match = re.search(pattern, title, re.IGNORECASE)
        if match:
            return match.group(1).replace(' ', '_')
    
    # If no specific product found, try to extract meaningful words
    # Remove stop words
    stop_words = {'item', 'good', 'condition', 'used', 'sale', 'campus', 'essential', 'everyday', 'useful', 'student', 'owned'}
    words = re.findall(r'\b\w+\b', title)
    meaningful_words = [w for w in words if w not in stop_words and len(w) > 2]
    
    if meaningful_words:
        return '_'.join(meaningful_words[:3])  # Take first 3 meaningful words
    
    return None

def sanitize_filename(name):
    """Convert a string to a valid filename"""
    if not name:
        return None
    # Remove special characters, keep alphanumeric, spaces, hyphens, underscores
    name = re.sub(r'[^\w\s-]', '', name)
    # Replace multiple spaces with single space
    name = re.sub(r'\s+', ' ', name)
    # Replace spaces with underscores
    name = name.replace(' ', '_')
    # Convert to lowercase
    name = name.lower()
    # Limit length
    if len(name) > 80:
        name = name[:80]
    return name

def get_listing_data():
    """Fetch listing data with image URLs from database"""
    query = """
    SELECT l.listing_id, l.title, li.image_url, li.image_id
    FROM listings l
    JOIN listing_images li ON l.listing_id = li.listing_id
    ORDER BY l.listing_id
    """
    
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
        
        listings = []
        for line in lines:
            if not line.strip():
                continue
            parts = line.split('\t')
            if len(parts) >= 4:
                listings.append({
                    'listing_id': parts[0],
                    'title': parts[1],
                    'image_url': parts[2],
                    'image_id': parts[3]
                })
        return listings
    except subprocess.CalledProcessError as e:
        print(f"Error querying database: {e.stderr}")
        sys.exit(1)

def extract_filename_from_url(image_url):
    """Extract filename from image URL"""
    # Remove /images/ prefix
    filename = image_url.replace('/images/', '')
    return filename

def get_file_extension(filename):
    """Get file extension"""
    return os.path.splitext(filename)[1].lower()

def rename_image_file(old_filename, new_filename, upload_dir):
    """Rename the physical image file"""
    old_path = os.path.join(upload_dir, old_filename)
    new_path = os.path.join(upload_dir, new_filename)
    
    if not os.path.exists(old_path):
        return False, f"File not found: {old_path}"
    
    if os.path.exists(new_path):
        return False, f"Target file already exists: {new_path}"
    
    try:
        os.rename(old_path, new_path)
        return True, None
    except Exception as e:
        return False, str(e)

def update_database_image_url(image_id, new_image_url):
    """Update image_url in the database"""
    query = f"UPDATE listing_images SET image_url = '{new_image_url}' WHERE image_id = {image_id};"
    
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
        print(f"Error updating database: {e.stderr}")
        return False

def main():
    print("=" * 60)
    print("Renaming Images by Object Name")
    print("=" * 60)
    print()
    
    # Check upload directory exists
    if not os.path.exists(UPLOAD_DIR):
        print(f"Error: Upload directory not found: {UPLOAD_DIR}")
        sys.exit(1)
    
    print("Step 1: Fetching listing data from database...")
    listings = get_listing_data()
    print(f"Found {len(listings)} listings with images")
    print()
    
    print("Step 2: Processing images...")
    success_count = 0
    error_count = 0
    skipped_count = 0
    used_filenames = {}  # Track used filenames to avoid duplicates
    
    for i, listing in enumerate(listings, 1):
        listing_id = listing['listing_id']
        title = listing['title']
        old_image_url = listing['image_url']
        image_id = listing['image_id']
        
        # Extract current filename
        old_filename = extract_filename_from_url(old_image_url)
        
        # Extract object name from title
        object_name = extract_object_name(title)
        
        if object_name:
            base_name = sanitize_filename(object_name)
        else:
            # Fallback: use sanitized title
            base_name = sanitize_filename(title)
        
        # If still too generic, use listing_id
        if not base_name or base_name in ['other', 'item', 'product', 'sale', 'condition']:
            base_name = f"listing_{listing_id[:8]}"
        
        extension = get_file_extension(old_filename)
        
        # Make filename unique by adding counter if needed
        new_filename = f"{base_name}{extension}"
        counter = 1
        while new_filename in used_filenames:
            new_filename = f"{base_name}_{counter}{extension}"
            counter += 1
        
        used_filenames[new_filename] = True
        
        # Skip if filename is the same
        if old_filename == new_filename:
            skipped_count += 1
            print(f"[{i}/{len(listings)}] Skipped (same name): {old_filename}")
            continue
        
        # Rename physical file
        success, error_msg = rename_image_file(old_filename, new_filename, UPLOAD_DIR)
        
        if not success:
            error_count += 1
            print(f"[{i}/{len(listings)}] ❌ Error: {old_filename} -> {error_msg}")
            continue
        
        # Update database
        new_image_url = f"/images/{new_filename}"
        if update_database_image_url(image_id, new_image_url):
            success_count += 1
            print(f"[{i}/{len(listings)}] ✅ Renamed: {old_filename} -> {new_filename}")
        else:
            error_count += 1
            # Try to rename back
            rename_image_file(new_filename, old_filename, UPLOAD_DIR)
            print(f"[{i}/{len(listings)}] ❌ Database update failed, reverted: {old_filename}")
    
    print()
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"✅ Successfully renamed: {success_count}")
    print(f"⏭️  Skipped (same name): {skipped_count}")
    print(f"❌ Errors: {error_count}")
    print(f"📊 Total processed: {len(listings)}")
    print()

if __name__ == "__main__":
    main()

