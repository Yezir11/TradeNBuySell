#!/bin/bash

# Setup Demo Images Script
# Copies images from DemoArtifacts/Images to backend/uploads and updates seed_data.sql

echo "=========================================="
echo "Setting up Demo Images for Listings"
echo "=========================================="
echo ""

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEMO_ARTIFACTS="${SCRIPT_DIR}/DemoArtifacts/Images"
UPLOADS_DIR="${SCRIPT_DIR}/backend/uploads"
SEED_DATA="${SCRIPT_DIR}/backend/src/main/resources/seed_data.sql"

# Create uploads directory if it doesn't exist
mkdir -p "${UPLOADS_DIR}"

echo "Step 1: Copying images from DemoArtifacts to uploads directory..."
echo ""

# Mapping of listing categories to DemoArtifacts folders
declare -A IMAGE_MAPPINGS=(
    # Listing ID -> [DemoArtifacts folder, image filename pattern]
    ["aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"]="used monitors - Google Search|monitor"
    ["bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"]="used headphones images - Google Search|headphone"
    ["cccccccc-cccc-cccc-cccc-cccccccccccc"]="used mobile images - Google Search|mobile"
    ["dddddddd-dddd-dddd-dddd-dddddddddddd"]="used chairs images - Google Search|chair"
    ["eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"]="used chairs images - Google Search|chair"
    ["ffffffff-ffff-ffff-ffff-ffffffffffff"]="used mobile images - Google Search|mobile"
    ["gggggggg-gggg-gggg-gggg-gggggggggggg"]="used monitors - Google Search|monitor"
    ["hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh"]="used monitors - Google Search|monitor"
    ["iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii"]="cycle images - Google Search|cycle"
    ["jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj"]="cycle images - Google Search|cycle"
    ["kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk"]="used mobile images - Google Search|mobile"
    ["llllllll-llll-llll-llll-llllllllllll"]="used mobile images - Google Search|mobile"
    ["mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm"]="used mobile images - Google Search|mobile"
)

# Function to copy image and return the filename
copy_image() {
    local folder_name="$1"
    local listing_id="$2"
    local image_index="$3"
    
    local source_folder="${DEMO_ARTIFACTS}/${folder_name}"
    
    if [ ! -d "${source_folder}" ]; then
        echo "  ⚠️  Folder not found: ${folder_name}"
        return 1
    fi
    
    # Find first available image
    local image_file=$(find "${source_folder}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -1)
    
    if [ -z "${image_file}" ]; then
        echo "  ⚠️  No images found in ${folder_name}"
        return 1
    fi
    
    # Get file extension
    local extension="${image_file##*.}"
    local extension_lower=$(echo "${extension}" | tr '[:upper:]' '[:lower:]')
    
    # Generate new filename: listing_id-image_index.extension
    local new_filename="${listing_id}-${image_index}.${extension_lower}"
    local dest_path="${UPLOADS_DIR}/${new_filename}"
    
    # Copy image
    cp "${image_file}" "${dest_path}"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Copied: ${new_filename}"
        echo "/images/${new_filename}"
        return 0
    else
        echo "  ✗ Failed to copy: ${image_file}"
        return 1
    fi
}

# Process each listing
echo "Copying images for listings..."
echo ""

declare -A IMAGE_URLS

for listing_id in "${!IMAGE_MAPPINGS[@]}"; do
    IFS='|' read -r folder_name pattern <<< "${IMAGE_MAPPINGS[$listing_id]}"
    
    echo "  Processing ${listing_id} (${folder_name})..."
    
    # Copy first image (index 0)
    image_url=$(copy_image "${folder_name}" "${listing_id}" "0")
    if [ $? -eq 0 ]; then
        IMAGE_URLS["${listing_id}_0"]="${image_url}"
    fi
    
    # For MacBook (listing aaaaaaaa...), copy second image
    if [ "${listing_id}" = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" ]; then
        # Get second image from folder
        second_image=$(find "${DEMO_ARTIFACTS}/${folder_name}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sed -n '2p')
        if [ -n "${second_image}" ]; then
            extension="${second_image##*.}"
            extension_lower=$(echo "${extension}" | tr '[:upper:]' '[:lower:]')
            new_filename="${listing_id}-1.${extension_lower}"
            cp "${second_image}" "${UPLOADS_DIR}/${new_filename}"
            if [ $? -eq 0 ]; then
                echo "  ✓ Copied: ${new_filename}"
                IMAGE_URLS["${listing_id}_1"]="/images/${new_filename}"
            fi
        fi
    fi
    
    echo ""
done

echo "Step 2: Updating seed_data.sql with actual image paths..."
echo ""

# Create backup
cp "${SEED_DATA}" "${SEED_DATA}.backup"
echo "  ✓ Created backup: seed_data.sql.backup"

# Update seed_data.sql with actual image paths
# This is a simple approach - we'll replace the placeholder paths
python3 << EOF
import re
import sys

seed_data_path = "${SEED_DATA}"
image_urls = {
$(for key in "${!IMAGE_URLS[@]}"; do
    listing_id=$(echo "$key" | cut -d'_' -f1)
    index=$(echo "$key" | cut -d'_' -f2)
    url="${IMAGE_URLS[$key]}"
    echo "    '${listing_id}_${index}': '${url}',"
done)
}

# Read seed data
with open(seed_data_path, 'r') as f:
    content = f.read()

# Replace image URLs
for key, url in image_urls.items():
    listing_id, index = key.split('_')
    index = int(index)
    
    # Find the INSERT statement for this listing_id
    pattern = rf"\(('{listing_id}',\s*')([^']+)(',\s*{index},)"
    replacement = rf"\1{url}\3"
    content = re.sub(pattern, replacement, content)

# Write back
with open(seed_data_path, 'w') as f:
    f.write(content)

print("  ✓ Updated seed_data.sql with actual image paths")
EOF

echo ""
echo "=========================================="
echo "Demo Images Setup Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Images copied to: ${UPLOADS_DIR}"
echo "  - seed_data.sql updated with actual image paths"
echo "  - Backup created: seed_data.sql.backup"
echo ""
echo "Next steps:"
echo "  1. Review the updated seed_data.sql"
echo "  2. Run setup-demo.sh to apply the updated seed data"
echo "  3. Start the backend to serve images"
echo ""


