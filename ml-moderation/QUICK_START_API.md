# 🚀 Quick Start: Flask ML Moderation API

## Simple Start (Minimal Dependencies)

The API can run in **mock mode** with just Flask installed:

```bash
cd ml-moderation

# Install minimal dependencies (only Flask)
pip3 install flask flask-cors pillow

# Start API
python3 api/app.py
```

The API will start on `http://localhost:5000` and run in **mock mode** (always returns 'safe').

---

## Full Start (With ML Model Support)

To enable real ML moderation:

### 1. Install All Dependencies
```bash
cd ml-moderation
pip3 install -r requirements.txt
```

### 2. Train the Model (if not already trained)
```bash
jupyter notebook notebooks/moderation_pipeline.ipynb
# Run all cells - model will be saved to models/model.pt
```

### 3. Start the API
```bash
export MODEL_PATH=./models/model.pt
export PORT=5000
python3 api/app.py
```

---

## Testing

### Health Check
```bash
curl http://localhost:5000/health
```

### Test Moderation
```bash
curl -X POST http://localhost:5000/moderate \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Listing",
    "description": "This is a test",
    "imageBase64": null
  }'
```

---

## What is Mock Mode?

**Mock Mode** means:
- ✅ API runs successfully
- ✅ Returns valid responses
- ✅ Always returns `label: "safe"` with high confidence
- ✅ Your Spring Boot app continues to work
- ✅ No errors or crashes

**This is perfect for:**
- Testing the integration
- Development when model isn't trained yet
- Ensuring your app works even if ML service is unavailable

---

## Troubleshooting

### "ImportError: cannot import name 'DistilBERTTokenizer'"
**Solution:** This is OK! The API will run in mock mode. Install transformers for real ML:
```bash
pip3 install transformers
```

### "Port 5000 already in use"
**Solution:** Use a different port:
```bash
export PORT=5001
python3 api/app.py
```

Then update `backend/src/main/resources/application.properties`:
```properties
app.moderation.api.url=http://localhost:5001
```

### API won't start
**Solution:** Check if Flask is installed:
```bash
pip3 install flask flask-cors
```

---

## Expected Output

When API starts successfully:
```
============================================================
🚀 ML Moderation API Starting...
============================================================
📁 Model path: ./models/model.pt
🖥️  Device: N/A
🌐 Port: 5000
============================================================
⚠️  ML dependencies not installed. Running in mock mode only.
   Install dependencies: pip3 install torch torchvision transformers
⚠️  Running in MOCK MODE - All predictions will return 'safe'
   This is OK for testing. Your application will work normally.
============================================================
📡 API running at http://localhost:5000
🏥 Health check: http://localhost:5000/health
🔍 Moderation: POST http://localhost:5000/moderate
============================================================
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
```

---

## Integration with Spring Boot

Once the Flask API is running:

1. ✅ Spring Boot will automatically call it when listings are created
2. ✅ If API is unavailable, Spring Boot continues normally (graceful degradation)
3. ✅ Flagged listings are automatically deactivated
4. ✅ Admin can review flagged listings in Admin Dashboard

---

## Next Steps

1. ✅ Start the Flask API (even in mock mode)
2. ✅ Test that Spring Boot can connect to it
3. ✅ Create a test listing and verify moderation is called
4. ✅ (Later) Train the model and enable real ML moderation

