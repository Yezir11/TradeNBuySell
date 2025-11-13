# 🚀 Quick Start Guide

## Step 1: Prepare Your Dataset

1. Create `data/dataset.csv` with columns: `image_path`, `title`, `description`, `label`
2. Place all images in `data/images/` directory
3. Labels must be one of: `safe`, `nsfw`, `weapon`, `alcohol`, `drugs`, `restricted`

Example:
```csv
image_path,title,description,label
item1.jpg,Used Laptop,Great condition laptop,safe
item2.jpg,Party Items,Alcohol and party supplies,alcohol
```

## Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

## Step 3: Train the Model

```bash
jupyter notebook notebooks/moderation_pipeline.ipynb
```

Run all cells. The model will be saved to `models/model.pt`.

## Step 4: Start Flask API

```bash
cd api
export MODEL_PATH=../models/model.pt
python app.py
```

API will be available at `http://localhost:5000`

## Step 5: Test the API

```bash
curl -X POST http://localhost:5000/moderate \
  -F "image=@path/to/image.jpg" \
  -F "title=Test Listing" \
  -F "description=Test description"
```

## Step 6: Integrate with Spring Boot

1. Run the SQL script:
```bash
mysql -u root -p tradenbysell < ../backend/src/main/resources/moderation_schema.sql
```

2. Ensure Flask API is running on port 5000

3. Spring Boot will automatically call the moderation API when listings are created

## Step 7: Access Admin Dashboard

Admin endpoints are available at:
- `GET /api/moderation/admin/flagged-listings` - View flagged listings
- `PUT /api/moderation/admin/log/{logId}/action` - Approve/Reject listings
- `GET /api/moderation/admin/statistics` - View moderation stats

## Troubleshooting

- **Model not found**: Ensure you've trained the model first (Step 3)
- **API connection error**: Check Flask API is running on port 5000
- **CUDA errors**: Set `device = torch.device('cpu')` in notebook if no GPU available

