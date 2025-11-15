# 🚀 Training Guide - Vision Transformer for Content Moderation

## ✅ What's Ready

1. **✅ Dataset CSV**: `data/dataset.csv` (1,740 entries)
   - Safe: 1,140 images
   - Drugs: 300 images
   - Alcohol: 200 images
   - Weapon: 100 images

2. **✅ Images**: `data/images/` (3,440 images)

3. **✅ Model Architecture**: `src/modeling/multimodal_model.py`
   - Vision Transformer (ViT-Base) for images
   - DistilBERT for text
   - Multimodal fusion + classification head

4. **✅ Dataset Class**: `src/modeling/dataset.py`
   - PyTorch Dataset implementation
   - Image preprocessing
   - Text tokenization

5. **✅ Training Notebook**: `notebooks/moderation_pipeline.ipynb`
   - 31 cells total (11 markdown, 20 code)
   - Complete ML pipeline

## 📋 Notebook Sections

The notebook includes:

1. **Setup and Imports** - All required libraries
2. **Dataset Details and Exploration** - EDA, label distribution, text statistics
3. **Data Preprocessing** - Dataset creation, train/val/test split, data loaders
4. **Model Architecture** - Multimodal model initialization and forward pass test
5. **Training Configuration** - Loss, optimizer, scheduler, hyperparameters
6. **Training Loop** - Complete training with progress bars, validation, early stopping
7. **Training History Visualization** - Loss and accuracy plots
8. **Load Best Model and Evaluate** - Test set evaluation, confusion matrix, classification report
9. **Save Final Model** - Save to `models/model.pt` for API deployment
10. **Test Model on Sample Images** - Visual predictions on sample images

## 🚀 How to Train

### Step 1: Install Dependencies

```bash
cd ml-moderation
pip install -r requirements.txt
```

**Note**: This will install:
- PyTorch (CPU or CUDA version)
- Transformers (HuggingFace)
- timm (Vision Transformers)
- Jupyter
- All other ML dependencies

### Step 2: Start Jupyter

```bash
cd ml-moderation
jupyter notebook
```

Or if using VS Code/Cursor:
- Open `notebooks/moderation_pipeline.ipynb`
- Select kernel (Python 3)
- Run all cells

### Step 3: Run the Notebook

**Option A: Run All Cells**
- In Jupyter: `Cell` → `Run All`
- In VS Code: Click "Run All" button

**Option B: Run Cell by Cell** (Recommended for first time)
- Run each cell sequentially
- Check outputs at each step
- Fix any issues before proceeding

### Step 4: Monitor Training

The training loop will show:
- Progress bars for each epoch
- Train/validation loss and accuracy
- Best model saves automatically
- Early stopping if validation loss doesn't improve

**Expected Training Time:**
- CPU: ~2-4 hours (depending on hardware)
- GPU (CUDA): ~30-60 minutes

### Step 5: Check Results

After training completes:
- Best model saved to: `models/best_model.pt`
- Final model saved to: `models/model.pt`
- Training plots displayed
- Test set evaluation metrics printed

## 📊 Model Architecture

**Multimodal Content Moderation Model:**
- **Image Encoder**: Vision Transformer (ViT-Base, 768-dim)
- **Text Encoder**: DistilBERT (768-dim)
- **Fusion**: Concatenation (1536-dim)
- **Classifier**: 3-layer MLP (1536 → 512 → 256 → 4)
- **Total Parameters**: ~150M (trainable)

**Output Classes:**
- 0: `safe`
- 1: `weapon`
- 2: `alcohol`
- 3: `drugs`

## ⚙️ Hyperparameters

- **Batch Size**: 16
- **Learning Rate**: 2e-5
- **Optimizer**: AdamW (weight_decay=0.01)
- **Scheduler**: ReduceLROnPlateau (factor=0.5, patience=3)
- **Epochs**: 10 (with early stopping patience=5)
- **Gradient Clipping**: max_norm=1.0
- **Dropout**: 0.3

## 📁 File Structure

```
ml-moderation/
├── notebooks/
│   └── moderation_pipeline.ipynb    # Training notebook
├── src/
│   └── modeling/
│       ├── multimodal_model.py      # Model architecture
│       └── dataset.py                # Dataset class
├── data/
│   ├── dataset.csv                   # Training data
│   └── images/                       # Image files
├── models/
│   ├── best_model.pt                 # Best model (during training)
│   └── model.pt                      # Final model (for API)
└── requirements.txt                  # Dependencies
```

## 🔧 Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'modeling'"

**Solution**: Make sure you're running from the `notebooks/` directory, or the notebook has the correct path setup in the first cell.

### Issue: "CUDA out of memory"

**Solution**: 
- Reduce batch size (change `batch_size = 16` to `batch_size = 8` or `4`)
- Use CPU instead (will be slower)

### Issue: "Image not found" warnings

**Solution**: 
- Check that images are in `data/images/`
- Verify image paths in `dataset.csv` match actual filenames

### Issue: Training is very slow

**Solution**:
- Use GPU if available (CUDA)
- Reduce batch size
- Reduce number of epochs for testing

## ✅ After Training

Once training completes and `models/model.pt` is created:

1. **Restart Flask API**:
   ```bash
   cd ml-moderation
   ./start_api.sh
   ```

2. **Test the API**:
   ```bash
   curl -X POST http://localhost:5002/moderate \
     -H "Content-Type: application/json" \
     -d '{"title": "Test", "description": "Test", "imageBase64": "..."}'
   ```

3. **The Flask API will automatically load the trained model** and use real predictions instead of mock mode.

## 🎯 Expected Results

After training, you should see:
- **Test Accuracy**: 70-90% (depending on data quality)
- **Model File**: `models/model.pt` (~600MB)
- **Training Plots**: Loss and accuracy curves
- **Confusion Matrix**: Per-class performance

The model will then be ready for production use in the Flask API!

