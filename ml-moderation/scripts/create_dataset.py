#!/usr/bin/env python3
"""
Create dataset.csv from existing images in scripts/dataset/
"""
import os
import pandas as pd
import glob
from pathlib import Path

def get_label_from_folder(folder_name, parent_folder):
    """Determine label based on folder structure"""
    if parent_folder == 'safe':
        return 'safe'
    elif 'weapon' in folder_name.lower():
        return 'weapon'
    elif 'drug' in folder_name.lower() or 'medicine' in folder_name.lower() or 'paraphernalia' in folder_name.lower():
        return 'drugs'
    elif 'alcohol' in folder_name.lower():
        return 'alcohol'
    elif 'nsfw' in folder_name.lower():
        return 'safe'  # Skip NSFW for now
    else:
        return 'safe'

def generate_description_from_filename(filename, label):
    """Generate a basic description from filename"""
    base = os.path.splitext(filename)[0]
    base = base.replace('_', ' ').replace('-', ' ')
    
    if label == 'safe':
        return f"This is a {base} in good condition, available for sale."
    elif label == 'weapon':
        return f"Item related to weapons or dangerous items: {base}"
    elif label == 'drugs':
        return f"Item related to drugs or medicines: {base}"
    elif label == 'alcohol':
        return f"Item related to alcohol: {base}"
    else:
        return f"Item: {base}"

def generate_title_from_filename(filename, label):
    """Generate a basic title from filename"""
    base = os.path.splitext(filename)[0]
    base = base.replace('_', ' ').replace('-', ' ')
    
    if label == 'safe':
        # Capitalize first letter of each word
        return ' '.join(word.capitalize() for word in base.split())
    else:
        # For prohibited items, make it less obvious in title
        return base.replace('drug', '').replace('weapon', '').replace('alcohol', '').strip()

def create_dataset():
    """Create dataset.csv from images in scripts/dataset/"""
    base_dir = Path(__file__).parent.parent.parent / 'scripts' / 'dataset'
    
    dataset_records = []
    
    # Process safe images
    safe_dir = base_dir / 'safe'
    if safe_dir.exists():
        for subfolder in safe_dir.iterdir():
            if subfolder.is_dir():
                images = list(subfolder.glob('*.jpg')) + list(subfolder.glob('*.png')) + list(subfolder.glob('*.webp'))
                for img_path in images:
                    label = 'safe'
                    filename = img_path.name
                    
                    # Create relative path (will be copied to ml-moderation/data/images/)
                    rel_path = f"images/{filename}"
                    
                    title = generate_title_from_filename(filename, label)
                    description = generate_description_from_filename(filename, label)
                    
                    dataset_records.append({
                        'image_path': rel_path,
                        'title': title,
                        'description': description,
                        'label': label
                    })
    
    # Process prohibited images
    prohibited_dir = base_dir / 'prohibited'
    if prohibited_dir.exists():
        for subfolder in prohibited_dir.iterdir():
            if subfolder.is_dir() and subfolder.name != 'nsfw_content':
                images = list(subfolder.glob('*.jpg')) + list(subfolder.glob('*.png'))
                for img_path in images:
                    label = get_label_from_folder(subfolder.name, 'prohibited')
                    filename = img_path.name
                    
                    # Create relative path
                    rel_path = f"images/{filename}"
                    
                    title = generate_title_from_filename(filename, label)
                    description = generate_description_from_filename(filename, label)
                    
                    dataset_records.append({
                        'image_path': rel_path,
                        'title': title,
                        'description': description,
                        'label': label
                    })
    
    # Create DataFrame
    df = pd.DataFrame(dataset_records)
    
    # Save to ml-moderation/data/dataset.csv
    output_dir = Path(__file__).parent.parent / 'data'
    output_dir.mkdir(exist_ok=True)
    output_file = output_dir / 'dataset.csv'
    
    df.to_csv(output_file, index=False)
    
    print(f"✅ Created dataset.csv with {len(df)} entries")
    print(f"✅ Saved to: {output_file}")
    print(f"\n📊 Label distribution:")
    print(df['label'].value_counts())
    
    return df, output_file

if __name__ == '__main__':
    create_dataset()

