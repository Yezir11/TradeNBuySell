# 🚀 Step-by-Step Run Instructions

## Complete Guide to Run the Content Moderation Pipeline

---

## Prerequisites Check

### 1. Verify Python Installation
```bash
python3 --version
# Should be Python 3.10 or higher
```

### 2. Check if Dataset Exists
```bash
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation
ls -la data/dataset.csv
ls -la data/images/ | head -5
```

If dataset doesn't exist, run:
```bash
python3 scripts/build_dataset_from_scripts.py
```

---

## Step 1: Install Dependencies

```bash
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation

# Install Python packages
pip3 install -r requirements.txt
```

**Expected time**: 5-10 minutes (depending on internet speed)

**What this installs:**
- PyTorch, torchvision
- Transformers (Hugging Face)
- timm (Vision Transformer)
- PIL, numpy, pandas
- scikit-learn
- matplotlib, seaborn
- SHAP, LIME (for explainability)
- Jupyter

---

## Step 2: Verify Dataset

```bash
# Check dataset exists and has correct format
python3 -c "
import pandas as pd
df = pd.read_csv('data/dataset.csv')
print(f'✅ Dataset: {len(df)} entries')
print(f'✅ Labels: {sorted(df[\"label\"].unique())}')
print(f'✅ Columns: {list(df.columns)}')
"
```

**Expected output:**
```
✅ Dataset: 1740 entries
✅ Labels: ['alcohol', 'drugs', 'safe', 'weapon']
✅ Columns: ['image_path', 'title', 'description', 'label']
```

---

## Step 3: Start Jupyter Notebook

### Option A: From Terminal
```bash
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation
jupyter notebook
```

This will:
- Open Jupyter in your browser
- Navigate to `notebooks/moderation_pipeline.ipynb`

### Option B: From VS Code / Cursor
- Open `notebooks/moderation_pipeline.ipynb`
- Click "Run All" or run cells sequentially

---

## Step 4: Run the Notebook

### Cell-by-Cell Execution (Recommended)

**Cell 1: Setup and Imports**
- Click "Run" on the first code cell
- Wait for imports to complete
- Check output: `✅ Using device: cpu` (or `cuda` if GPU available)

**Cell 2: Data Loading**
- Run the data loading cell
- Verify: `✅ Total samples: 1740`
- Check: `✅ Classes: {0: 'safe', 1: 'weapon', 2: 'alcohol', 3: 'drugs'}`

**Cell 3: Train/Validation Split**
- Run the split cell
- Verify: `✅ Train samples: 1392`, `✅ Validation samples: 348`

**Cell 4: Exploratory Data Analysis**
- Run EDA cells
- View visualizations (class distribution, sample images, token lengths)

**Cell 5: Model Architecture**
- Run model initialization
- Check parameter count (~219M parameters)
- Verify model structure

**Cell 6: Training Configuration**
- Run training config cell
- Verify: epochs, learning rate, optimizer settings

**Cell 7: Training Loop** ⏱️ **LONGEST STEP**
- Run the training cell
- **This will take 1.5-2 hours on CPU, 6-8 minutes on GPU**
- Monitor progress bars
- Watch for early stopping

**Cell 8: Training History Plot**
- Run after training completes
- View loss and accuracy curves

**Cell 9: Load Best Model**
- Run to load the best checkpoint
- Verify: `✅ Loaded best model from epoch X`

**Cell 10: Evaluation**
- Run evaluation cell
- View metrics: accuracy, precision, recall, F1
- See confusion matrix

**Cell 11: Explainability Demo**
- Run explainability cell
- View Grad-CAM heatmaps for images
- View SHAP token importance for text
- See examples for each class

**Cell 12: Save Final Model**
- Run to save model for API deployment
- Verify: `✅ Model saved to ../models/model.pt`

---

## Step 5: Verify Training Success

```bash
# Check if model was saved
ls -lh models/model.pt

# Check model size (should be ~800-900 MB)
du -h models/model.pt
```

---

## Quick Start (Run All at Once)

If you want to run everything automatically:

```bash
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation

# Convert notebook to Python script and run
jupyter nbconvert --to script notebooks/moderation_pipeline.ipynb
python3 notebooks/moderation_pipeline.py
```

**Note**: This runs everything but you won't see visualizations. Better to use Jupyter.

---

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'torch'"
**Solution:**
```bash
pip3 install torch torchvision transformers timm
```

### Issue: "CUDA out of memory"
**Solution:**
- Reduce batch size to 8:
  ```python
  batch_size = 8  # Instead of 16
  ```

### Issue: "Dataset CSV not found"
**Solution:**
```bash
python3 scripts/build_dataset_from_scripts.py
```

### Issue: "Images not found"
**Solution:**
```bash
# Verify images exist
ls data/images/*.jpg | wc -l
# Should show 1740 images
```

### Issue: Training is too slow
**Solutions:**
1. Use GPU if available
2. Reduce epochs: `num_epochs = 5` for testing
3. Reduce batch size if memory constrained
4. Freeze pretrained weights (faster but less accurate)

---

## Expected Outputs

### During Training:
```
Epoch 1/10 [Train]: 100%|████████| 87/87 [05:30<00:00, loss=0.8234, acc=0.7123]
Epoch 1/10 [Val]: 100%|████████| 22/22 [01:20<00:00, loss=0.6543, acc=0.7890]

Epoch 1:
  Train Loss: 0.8234, Train Acc: 0.7123
  Val Loss: 0.6543, Val Acc: 0.7890
  ✅ Saved best model (val_loss: 0.6543)
```

### After Training:
```
📊 Overall Metrics:
  Accuracy: 0.8567
  Macro Precision: 0.8423
  Macro Recall: 0.8512
  Macro F1-Score: 0.8467

📊 Per-Class Metrics:
  safe     : Precision=0.9234, Recall=0.9123, F1=0.9178
  weapon   : Precision=0.7890, Recall=0.7654, F1=0.7771
  alcohol  : Precision=0.8123, Recall=0.8012, F1=0.8067
  drugs    : Precision=0.8456, Recall=0.8234, F1=0.8344
```

---

## Next Steps After Training

1. **Review Results**: Check accuracy and confusion matrix
2. **View Explainability**: See Grad-CAM and SHAP visualizations
3. **Deploy Model**: Use Flask API (`api/app.py`)
4. **Integrate**: Connect to Spring Boot backend

---

## Time Breakdown

| Step | Time (CPU) | Time (GPU) |
|------|------------|------------|
| Install dependencies | 5-10 min | 5-10 min |
| Data loading | 1-2 min | 30 sec |
| EDA | 2-3 min | 1 min |
| Model init | 1 min | 30 sec |
| **Training** | **1.5-2 hours** | **6-8 min** |
| Evaluation | 2-3 min | 1 min |
| Explainability | 5-10 min | 2-3 min |
| **Total** | **~2 hours** | **~10-15 min** |

---

## Tips

1. **Start with fewer epochs** for testing:
   ```python
   num_epochs = 3  # Quick test
   ```

2. **Monitor progress**: Watch validation loss - if it stops improving, training is done

3. **Save checkpoints**: Best model is automatically saved

4. **Use GPU if available**: Massive time savings

5. **Check memory**: If errors occur, reduce batch size

---

## Quick Command Reference

```bash
# Navigate to project
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation

# Install dependencies
pip3 install -r requirements.txt

# Build dataset (if needed)
python3 scripts/build_dataset_from_scripts.py

# Start Jupyter
jupyter notebook

# Or run from command line (no visualizations)
jupyter nbconvert --to script notebooks/moderation_pipeline.ipynb
python3 notebooks/moderation_pipeline.py
```

---

## Success Indicators

✅ **Training Started Successfully:**
- Progress bars appear
- Loss values decreasing
- Accuracy increasing

✅ **Training Completed:**
- Best model saved to `models/best_model.pt`
- Final model saved to `models/model.pt`
- Evaluation metrics displayed

✅ **Model Ready:**
- `models/model.pt` exists
- File size ~800-900 MB
- Can be loaded by Flask API



