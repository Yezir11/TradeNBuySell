# 📊 Dataset Information

## Dataset Overview

The content moderation dataset has been successfully created with the following structure:

### Statistics

- **Total Entries**: 420
- **Safe Items**: 220 (real images from DemoArtifacts)
- **Prohibited Items**: 200 (placeholder images)

### Class Distribution

| Class | Count | Source |
|-------|-------|--------|
| `safe` | 220 | Real images from DemoArtifacts |
| `weapon` | 50 | Placeholder images |
| `drugs` | 50 | Placeholder images |
| `nsfw` | 50 | Placeholder images |
| `alcohol` | 50 | Placeholder images |

### Safe Items Breakdown

| Category | Images | Source Folder |
|----------|--------|--------------|
| Cycles | 50 | `cycle images - Google Search` |
| Air Coolers | 38 | `used air cooler images - Google Search` |
| Chairs | 18 | `used chairs images - Google Search` |
| Headphones | 25 | `used headphones images - Google Search` |
| Mattress | 25 | `used mattress images - Google Search` |
| Mobile Phones | 15 | `used mobile images - Google Search` |
| Monitors | 35 | `used monitors - Google Search` |
| Sneakers | 14 | `used sneakers - Google Search` |

## Dataset Structure

```
data/
├── dataset.csv          # Main dataset file
└── images/             # All image files
    ├── cycles_safe_*.jpg
    ├── air_coolers_safe_*.jpg
    ├── chairs_safe_*.jpg
    ├── headphones_safe_*.jpg
    ├── mattress_safe_*.jpg
    ├── mobile_phones_safe_*.jpg
    ├── monitors_safe_*.jpg
    ├── sneakers_safe_*.jpg
    ├── weapons_weapon_*.jpg
    ├── drugs_drugs_*.jpg
    ├── nsfw_nsfw_*.jpg
    └── alcohol_tobacco_alcohol_*.jpg
```

## CSV Format

The `dataset.csv` file has the following columns:

- `image_path`: Relative path to image (e.g., `images/cycles_safe_001.jpg`)
- `title`: Listing title (e.g., "Used Bicycle")
- `description`: Listing description (e.g., "Used bicycle in good condition...")
- `label`: Class label (`safe`, `weapon`, `drugs`, `nsfw`, `alcohol`)

## Next Steps

1. **Review the dataset**: Check `data/dataset.csv` to verify entries
2. **Improve prohibited items**: Replace placeholder images with real prohibited item images for better model training
3. **Train the model**: Open `notebooks/moderation_pipeline.ipynb` and run all cells
4. **Evaluate**: Review model performance and adjust as needed

## Improving the Dataset

### For Better Model Performance:

1. **Add More Prohibited Item Images**:
   - Use the `scrape_real_images.py` script with API keys
   - Manually collect images from appropriate sources
   - Ensure images are relevant and properly labeled

2. **Balance the Dataset**:
   - Currently: 220 safe vs 200 prohibited
   - Ideal: Equal distribution (e.g., 200 each)
   - Consider data augmentation for minority classes

3. **Quality Control**:
   - Verify all images are correctly labeled
   - Remove any mislabeled or low-quality images
   - Ensure images are clear and relevant

## Scripts Available

- `scripts/build_dataset.py`: Creates placeholder dataset
- `scripts/use_existing_images.py`: Uses real images from DemoArtifacts
- `scripts/scrape_real_images.py`: Scrapes real images from APIs (requires API keys)

## Notes

- **Placeholder Images**: The prohibited item images are currently placeholders (colored squares with text). For production use, replace these with real images.
- **Image Quality**: All images are resized to 224x224 for model training
- **Format**: All images are saved as JPEG format

