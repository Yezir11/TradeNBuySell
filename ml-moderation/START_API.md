# 🚀 How to Start the Flask ML Moderation API

## Quick Start (Easiest Method)

```bash
cd ml-moderation
./start_api.sh
```

This script will:
- Check for model file
- Install dependencies if needed
- Start the Flask API on port 5000

---

## Manual Start

### Method 1: Using Environment Variables

```bash
cd ml-moderation
export MODEL_PATH=./models/model.pt
export PORT=5000
python3 api/app.py
```

### Method 2: Using the Start Script

```bash
cd ml-moderation
bash start_api.sh
```

---

## What Happens When You Start?

### ✅ If Model Exists:
- Model loads successfully
- API runs in **REAL MODE** - actual ML predictions

### ⚠️ If Model Doesn't Exist:
- API runs in **MOCK MODE** - always returns 'safe'
- Your application continues to work
- No errors or crashes

---

## Testing the API

### 1. Health Check
```bash
curl http://localhost:5000/health
```

Expected response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "model_status": "loaded",
  "device": "cpu",
  "model_path": "./models/model.pt"
}
```

### 2. Test Moderation
```bash
curl -X POST http://localhost:5000/moderate \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Listing",
    "description": "This is a test listing",
    "imageBase64": "base64_encoded_image_here"
  }'
```

---

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'flask'"
**Solution:**
```bash
cd ml-moderation
pip3 install -r requirements.txt
```

### Issue: "Model file not found"
**Solution:**
This is OK! The API will run in mock mode. To enable real moderation:
1. Train the model first: `jupyter notebook notebooks/moderation_pipeline.ipynb`
2. Save model to `models/model.pt`
3. Restart the API

### Issue: "Port 5000 already in use"
**Solution:**
```bash
export PORT=5001
python3 api/app.py
```
Then update `backend/src/main/resources/application.properties`:
```properties
app.moderation.api.url=http://localhost:5001
```

---

## Expected Output

When you start the API, you should see:
```
============================================================
🚀 ML Moderation API Starting...
============================================================
📁 Model path: ./models/model.pt
🖥️  Device: cpu
🌐 Port: 5000
============================================================
⚠️  Warning: Model file not found at ./models/model.pt
   Moderation API will run in mock mode (always returns 'safe')
   Train the model first: jupyter notebook notebooks/moderation_pipeline.ipynb
⚠️  Running in MOCK MODE - All predictions will return 'safe'
   To enable real moderation:
   1. Train the model: jupyter notebook notebooks/moderation_pipeline.ipynb
   2. Ensure model is saved to models/model.pt
   3. Restart this API
============================================================
📡 API running at http://localhost:5000
🏥 Health check: http://localhost:5000/health
🔍 Moderation: POST http://localhost:5000/moderate
============================================================
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://[your-ip]:5000
```

---

## Next Steps

Once the API is running:
1. ✅ Your Spring Boot backend will automatically use it
2. ✅ When users create listings, moderation will run automatically
3. ✅ Flagged listings will be deactivated (pending admin review)

---

## Stopping the API

Press `Ctrl+C` in the terminal where it's running.

