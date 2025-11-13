# 🧠 ML-Based Content Moderation for TradeNBuy

Complete multimodal ML pipeline for content moderation using Vision Transformer (ViT) and DistilBERT.

## 📋 Overview

This system automatically moderates marketplace listings by analyzing both images and text to detect prohibited content. It classifies listings into:
- `safe`: Approved content
- `weapon`: Weapons or dangerous items
- `alcohol`: Alcohol-related items
- `drugs`: Drug-related items (including medicines and paraphernalia)

**Note:** NSFW content detection has been removed from this version.

## 🏗️ Architecture

```
┌─────────────────┐
│  Jupyter        │  →  Train & Evaluate Model
│  Notebook       │  →  Generate Explanations
└─────────────────┘
         │
         ↓
┌─────────────────┐
│  Flask API      │  →  Serve Model Predictions
│  (Port 5000)    │  →  Generate Heatmaps & Explanations
└─────────────────┘
         │
         ↓
┌─────────────────┐
│  Spring Boot    │  →  Integrate with Main App
│  (Port 8080)    │  →  Store Moderation Logs
└─────────────────┘
```

## 📁 Project Structure

```
ml-moderation/
├── notebooks/
│   └── moderation_pipeline.ipynb    # Complete ML pipeline
├── src/
│   ├── modeling/
│   │   ├── multimodal_model.py      # ViT + DistilBERT model
│   │   └── dataset.py                # PyTorch Dataset
│   └── explain/
│       ├── gradcam.py                # Grad-CAM for images
│       └── text_explain.py           # SHAP/LIME for text
├── api/
│   └── app.py                        # Flask REST API
├── data/
│   ├── dataset.csv                   # Training data (image_path, title, description, label)
│   └── images/                       # Image files
├── models/
│   └── model.pt                      # Trained model (generated after training)
├── requirements.txt                  # Python dependencies
├── Dockerfile                        # Docker configuration
└── README.md                         # This file
```

## 🚀 Setup Instructions

### Prerequisites

- Python 3.10+
- CUDA-capable GPU (optional, for faster training)
- MySQL database (for Spring Boot integration)
- Docker (optional, for containerized deployment)

### 1. Install Dependencies

```bash
cd ml-moderation
pip install -r requirements.txt
```

### 2. Prepare Dataset

Create a `data/dataset.csv` file with the following columns:
- `image_path`: Relative path to image from `data/images/`
- `title`: Listing title
- `description`: Listing description
- `label`: One of `safe`, `weapon`, `alcohol`, `drugs`

Example:
```csv
image_path,title,description,label
item1.jpg,Used Laptop,Great condition laptop for sale,safe
item2.jpg,Party Supplies,Alcohol and party items,alcohol
```

Place all images in `data/images/` directory.

### 3. Train the Model

Open the Jupyter notebook:
```bash
jupyter notebook notebooks/moderation_pipeline.ipynb
```

Run all cells to:
1. Load and preprocess data
2. Perform exploratory data analysis
3. Train the multimodal model
4. Evaluate performance
5. Generate explanations
6. Save the trained model

The trained model will be saved to `models/model.pt`.

### 4. Run Flask API

```bash
cd api
export MODEL_PATH=../models/model.pt
export PORT=5000
python app.py
```

Or using Docker:
```bash
docker build -t moderation-api .
docker run -p 5000:5000 -v $(pwd)/models:/app/models moderation-api
```

### 5. Test the API

```bash
curl -X POST http://localhost:5000/moderate \
  -F "image=@path/to/image.jpg" \
  -F "title=Listing Title" \
  -F "description=Listing description"
```

Response:
```json
{
  "label": "safe",
  "confidence": 0.95,
  "should_flag": false,
  "all_probabilities": {
    "safe": 0.95,
    "weapon": 0.02,
    "alcohol": 0.02,
    "drugs": 0.01
  },
  "image_heatmap": "data:image/png;base64,...",
  "text_explanation": {
    "tokens": ["laptop", "used", "good"],
    "scores": [0.8, 0.6, 0.5]
  }
}
```

## 🔗 Spring Boot Integration

### 1. Create Moderation Logs Table

Run the SQL script:
```bash
mysql -u root -p tradenbysell < ../backend/src/main/resources/moderation_schema.sql
```

### 2. Configure Moderation API URL

Add to `backend/src/main/resources/application.properties`:
```properties
app.moderation.api.url=http://localhost:5000
```

### 3. API Endpoints

#### Moderate a Listing
```http
POST /api/moderation/listing/{listingId}
Authorization: Bearer <token>
```

#### Moderate Content (New Listing)
```http
POST /api/moderation/content
Content-Type: multipart/form-data
Authorization: Bearer <token>

image: <file>
title: <string>
description: <string>
```

#### Get Flagged Listings (Admin)
```http
GET /api/moderation/admin/flagged-listings?page=0&size=20
Authorization: Bearer <admin_token>
```

#### Update Moderation Action (Admin)
```http
PUT /api/moderation/admin/log/{logId}/action
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "action": "APPROVED|REJECTED|BLACKLISTED",
  "reason": "Reason for action"
}
```

#### Get Moderation Statistics (Admin)
```http
GET /api/moderation/admin/statistics
Authorization: Bearer <admin_token>
```

## 📊 Model Architecture

### Multimodal Model

- **Image Encoder**: Vision Transformer (ViT-B/32) - 768-dim embeddings
- **Text Encoder**: DistilBERT - 768-dim embeddings
- **Fusion**: Concatenated → FC(1536→512) → FC(512→256) → Classifier(256→6)
- **Total Parameters**: ~110M (mostly from pretrained models)

### Training Configuration

- **Optimizer**: AdamW (lr=2e-5, weight_decay=0.01)
- **Loss**: CrossEntropyLoss
- **Batch Size**: 16
- **Epochs**: 10 (with early stopping)
- **Learning Rate Scheduler**: ReduceLROnPlateau

## 🔍 Explainability

### Image Explanations (Grad-CAM)

- Highlights regions in the image that influenced the prediction
- Generates heatmap overlay on original image
- Returns base64-encoded image

### Text Explanations (SHAP)

- Identifies important tokens in title/description
- Provides importance scores for each token
- Returns top-k tokens with highest impact

## 🐳 Docker Deployment

### Build Image
```bash
docker build -t moderation-api .
```

### Run Container
```bash
docker run -d \
  -p 5000:5000 \
  -v $(pwd)/models:/app/models \
  -e MODEL_PATH=/app/models/model.pt \
  moderation-api
```

## 📝 Notes

1. **Model Training**: Requires GPU for reasonable training time (CPU will work but be slow)
2. **Dataset Size**: Minimum 100-200 samples per class recommended
3. **API Performance**: First request may be slow due to model loading
4. **Memory Requirements**: ~4GB RAM minimum, 8GB+ recommended
5. **Image Format**: Supports JPEG, PNG, WebP (converted to RGB)

## 🔧 Troubleshooting

### Model Not Found
- Ensure `models/model.pt` exists after training
- Check `MODEL_PATH` environment variable

### CUDA Out of Memory
- Reduce batch size in training
- Use CPU mode: `device = torch.device('cpu')`

### API Connection Errors
- Verify Flask API is running on port 5000
- Check `app.moderation.api.url` in Spring Boot config

## 📚 References

- [Vision Transformer (ViT)](https://arxiv.org/abs/2010.11929)
- [DistilBERT](https://arxiv.org/abs/1910.01108)
- [Grad-CAM](https://arxiv.org/abs/1610.02391)
- [SHAP](https://github.com/slundberg/shap)

## 📄 License

Part of the TradeNBuySell project.

