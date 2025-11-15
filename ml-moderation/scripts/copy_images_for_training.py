#!/usr/bin/env python3
"""
Copy images from scripts/dataset/ to ml-moderation/data/images/ for training
"""
import os
import shutil
from pathlib import Path

def copy_images():
    """Copy all images to ml-moderation/data/images/"""
    base_dir = Path(__file__).parent.parent.parent / 'scripts' / 'dataset'
    target_dir = Path(__file__).parent.parent / 'data' / 'images'
    
    target_dir.mkdir(parents=True, exist_ok=True)
    
    copied = 0
    skipped = 0
    
    # Copy safe images
    safe_dir = base_dir / 'safe'
    if safe_dir.exists():
        for subfolder in safe_dir.iterdir():
            if subfolder.is_dir():
                images = list(subfolder.glob('*.jpg')) + list(subfolder.glob('*.png')) + list(subfolder.glob('*.webp'))
                for img_path in images:
                    target_path = target_dir / img_path.name
                    if not target_path.exists():
                        shutil.copy2(img_path, target_path)
                        copied += 1
                    else:
                        skipped += 1
    
    # Copy prohibited images
    prohibited_dir = base_dir / 'prohibited'
    if prohibited_dir.exists():
        for subfolder in prohibited_dir.iterdir():
            if subfolder.is_dir() and subfolder.name != 'nsfw_content':
                images = list(subfolder.glob('*.jpg')) + list(subfolder.glob('*.png'))
                for img_path in images:
                    target_path = target_dir / img_path.name
                    if not target_path.exists():
                        shutil.copy2(img_path, target_path)
                        copied += 1
                    else:
                        skipped += 1
    
    print(f"✅ Copied {copied} images to {target_dir}")
    print(f"⚠️  Skipped {skipped} duplicate images")
    print(f"📁 Total images in target: {len(list(target_dir.glob('*.jpg')) + list(target_dir.glob('*.png')) + list(target_dir.glob('*.webp')))}")

if __name__ == '__main__':
    copy_images()

