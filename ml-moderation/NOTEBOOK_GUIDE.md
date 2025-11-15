# 📓 Complete Moderation Pipeline Notebook Guide

## Overview

The **`notebooks/moderation_pipeline.ipynb`** contains the complete end-to-end ML pipeline from data loading to explainability demo. Everything is self-contained in a single Jupyter notebook.

## What's Included

### ✅ Part 1: Setup and Imports
- All necessary libraries
- Device configuration (CPU/GPU)
- Model and utility imports

### ✅ Part 2: Data Loading & Preprocessing
- Load dataset from CSV
- Initialize tokenizer
- Create PyTorch datasets
- Train/validation split (80/20)

### ✅ Part 3: Exploratory Data Analysis
- Class distribution visualization
- Sample listings preview
- Token length distribution analysis

### ✅ Part 4: Model Architecture
- Multimodal model initialization (ViT + DistilBERT)
- Parameter counting
- Architecture visualization

### ✅ Part 5: Training Loop
- Training configuration
- Training and validation loops
- Early stopping
- Checkpoint saving
- Training history plots

### ✅ Part 6: Evaluation
- Load best model
- Comprehensive metrics (accuracy, precision, recall, F1)
- Per-class evaluation
- Confusion matrix
- Classification report

### ✅ Part 7: Explainability Demo
- Select examples (one per class)
- **Image Explanations**: Grad-CAM heatmaps
- **Text Explanations**: SHAP token importance
- Visualizations for each example

### ✅ Part 8: Save Final Model
- Save model for API deployment
- Include all metadata

## Classes

The model classifies into **4 classes**:
- `safe`: Approved content
- `weapon`: Weapons or dangerous items
- `alcohol`: Alcohol-related items
- `drugs`: Drug-related items

**Note:** NSFW has been removed.

## Usage

1. **Open the notebook:**
   ```bash
   jupyter notebook notebooks/moderation_pipeline.ipynb
   ```

2. **Run all cells sequentially:**
   - The notebook is designed to run from top to bottom
   - Each cell builds on the previous one

3. **Expected outputs:**
   - Data statistics
   - Training progress
   - Evaluation metrics
   - Explainability visualizations
   - Saved model at `models/model.pt`

## Requirements

- Dataset must be prepared: `data/dataset.csv` and `data/images/`
- All dependencies from `requirements.txt` installed
- GPU recommended (but CPU will work)

## Next Steps

After running the notebook:
1. Model will be saved to `models/model.pt`
2. Use Flask API (`api/app.py`) for production serving
3. Integrate with Spring Boot backend

## Notes

- **Everything is in the notebook** - no need to run separate scripts
- **Explainability is included** - see Part 7 for demos
- **Model is ready for deployment** - Part 8 saves everything needed




