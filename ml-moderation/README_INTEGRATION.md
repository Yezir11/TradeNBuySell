# ML Moderation Integration Guide

## Overview
The ML moderation system is integrated into the TradeNBuySell application to automatically flag prohibited content.

## Architecture

### Components
1. **Flask API** (`ml-moderation/api/app.py`): ML model serving API
2. **Spring Boot Service** (`ModerationService.java`): Calls Flask API and stores results
3. **Admin Dashboard**: Frontend interface for reviewing flagged listings

## Setup Instructions

### 1. Train the Model
```bash
cd ml-moderation/notebooks
jupyter notebook moderation_pipeline.ipynb
# Run all cells to train the model
# Model will be saved to ../models/best_model.pt
```

### 2. Start Flask API
```bash
cd ml-moderation
export MODEL_PATH=../models/best_model.pt
python api/app.py
# API runs on http://localhost:5000
```

### 3. Configure Spring Boot
Ensure `application.properties` has:
```properties
app.moderation.api.url=http://localhost:5000
```

### 4. Start Spring Boot
```bash
cd backend
mvn spring-boot:run
```

## Integration Flow

### Listing Creation Flow
1. User creates listing via `POST /api/listings`
2. User uploads images via `POST /api/listings/{listingId}/images`
3. **Automatic moderation triggered** after images are uploaded
4. If flagged (`should_flag = true`):
   - Listing is set to `isActive = false`
   - Moderation log is created with `adminAction = PENDING`
   - Listing appears in admin dashboard for review

### Admin Review Flow
1. Admin opens Admin Dashboard → Moderation tab
2. Views flagged listings with:
   - ML prediction (label, confidence)
   - Image heatmap (Grad-CAM visualization)
   - Text explanation (important tokens)
3. Admin takes action:
   - **APPROVED**: Listing activated, made visible
   - **REJECTED**: Listing remains inactive
   - **BLACKLISTED**: Listing inactive + user suspended

## API Endpoints

### Flask API (`http://localhost:5000`)
- `GET /health`: Health check
- `POST /moderate`: Content moderation
  - Accepts JSON: `{title, description, imageBase64}`
  - Returns: `{label, confidence, should_flag, image_heatmap, text_explanation}`

### Spring Boot API (`http://localhost:8080`)
- `POST /api/moderation/listing/{listingId}`: Moderate existing listing
- `GET /api/moderation/admin/flagged-listings`: Get flagged listings (Admin)
- `PUT /api/moderation/admin/log/{logId}/action`: Admin action (Approve/Reject/Blacklist)
- `GET /api/moderation/admin/statistics`: Moderation statistics (Admin)

## Testing

### Test Moderation API
```bash
# Health check
curl http://localhost:5000/health

# Test moderation (with base64 image)
curl -X POST http://localhost:5000/moderate \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Listing",
    "description": "This is a test",
    "imageBase64": "base64_encoded_image_string"
  }'
```

### Test Integration
1. Create a listing via frontend
2. Upload images
3. Check admin dashboard → Moderation tab
4. Review flagged listings

## Troubleshooting

### Flask API not starting
- Check if model file exists at `MODEL_PATH`
- Verify Python dependencies: `pip install -r requirements.txt`
- Check port 5000 is not in use

### Spring Boot can't connect to Flask API
- Verify Flask API is running: `curl http://localhost:5000/health`
- Check `app.moderation.api.url` in `application.properties`
- Check firewall/network settings

### No flagged listings appearing
- Check if listings have images (moderation requires images)
- Verify moderation logs in database: `SELECT * FROM moderation_logs`
- Check Spring Boot logs for errors

## Production Deployment

### Docker Deployment
```bash
# Build Flask API image
cd ml-moderation
docker build -t moderation-api .

# Run container
docker run -d \
  -p 5000:5000 \
  -v $(pwd)/models:/app/models \
  -e MODEL_PATH=/app/models/best_model.pt \
  moderation-api
```

### Environment Variables
- `MODEL_PATH`: Path to trained model (default: `../models/model.pt`)
- `PORT`: Flask API port (default: 5000)
- `DEVICE`: `cuda` or `cpu` (auto-detected)

## Notes
- Moderation runs **asynchronously** after image upload
- If moderation API is unavailable, listing creation still succeeds (graceful degradation)
- Flagged listings are automatically deactivated but can be approved by admin




