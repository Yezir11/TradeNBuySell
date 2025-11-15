# 📊 Explainability Demo - Usage Guide

## Overview

The explainability cell has been updated to automatically load a trained model from a checkpoint file. This allows you to run explainability analysis without retraining the model.

## Model Loading

The cell will automatically:

1. **Look for saved models** in this order:
   - First: `../models/best_model.pt` (best validation performance)
   - Fallback: `../models/model.pt` (final trained model)

2. **Load model architecture** with saved parameters:
   - `num_classes`, `image_embed_dim`, `text_embed_dim`
   - `hidden_dim`, `dropout`
   - `title_weight`, `desc_weight`

3. **Load model weights** from the checkpoint

4. **Set model to evaluation mode**

## Prerequisites

Before running the explainability cell, make sure:

1. ✅ **Model is trained and saved**
   - Run the training cells first
   - Model will be saved to `../models/best_model.pt` or `../models/model.pt`

2. ✅ **Dataset is loaded** (or will be auto-loaded)
   - The cell will load the dataset if not already loaded
   - Uses `../data/dataset.csv` and `../data/images/`

3. ✅ **Device is set** (CPU, CUDA, or MPS)
   - Should be defined in earlier cells
   - Model will be moved to the correct device

## What the Cell Does

1. **Loads the trained model** from checkpoint
2. **Selects examples** (one per class: safe, weapon, alcohol, drugs)
3. **Generates predictions** for each example
4. **Creates Grad-CAM heatmaps** showing which image regions influenced the prediction
5. **Generates text explanations** showing which words/tokens were important

## Output

For each example, you'll see:
- ✅ Title and description
- ✅ True label vs predicted label
- ✅ Confidence score
- ✅ Class probabilities
- ✅ Image heatmap (Grad-CAM)
- ✅ Text token importance (SHAP)

## Troubleshooting

### Model Not Found
```
⚠️  Model file not found at ../models/best_model.pt
```
**Solution:** Train the model first by running the training cells.

### Device Error
If you see device-related errors, make sure:
- Device is defined: `device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')`
- Or use MPS for Apple Silicon: `device = torch.device('mps')`

### Dataset Not Loaded
The cell will automatically load the dataset if needed. Make sure:
- `../data/dataset.csv` exists
- `../data/images/` directory contains the images

## Example Usage

```python
# The cell handles everything automatically:
# 1. Loads model
# 2. Loads dataset (if needed)
# 3. Runs explainability demo
# 4. Displays results

# Just run the cell - no additional setup needed!
```

## Model Files

- **`best_model.pt`**: Best model based on validation loss (recommended)
- **`model.pt`**: Final model after all training epochs

Both files contain:
- `model_state_dict`: Model weights
- `num_classes`, `image_embed_dim`, etc.: Architecture parameters
- `epoch`, `val_loss`, `val_acc`: Training metadata




