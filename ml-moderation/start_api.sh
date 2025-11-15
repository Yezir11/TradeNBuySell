#!/bin/bash
# Quick start script for Flask Moderation API

echo "🚀 Starting ML Moderation API..."
echo ""

# Check if model path is set
if [ -z "$MODEL_PATH" ]; then
    export MODEL_PATH=./models/model.pt
    echo "📁 Using default model path: $MODEL_PATH"
else
    echo "📁 Using model path: $MODEL_PATH"
fi

# Set port (default 5002 to avoid macOS AirPlay conflict on 5000)
export PORT=${PORT:-5002}
echo "🌐 Port: $PORT"
echo ""

# Check if model exists
if [ ! -f "$MODEL_PATH" ]; then
    echo "⚠️  Warning: Model file not found at $MODEL_PATH"
    echo "   API will run in MOCK MODE (always returns 'safe')"
    echo ""
    echo "   To enable real moderation:"
    echo "   1. Train the model first:"
    echo "      cd ml-moderation"
    echo "      jupyter notebook notebooks/moderation_pipeline.ipynb"
    echo "   2. Ensure model is saved to models/model.pt"
    echo ""
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 not found"
    exit 1
fi

# Check if Flask is installed
if ! python3 -c "import flask" 2>/dev/null; then
    echo "⚠️  Flask not found. Installing dependencies..."
    pip3 install -r requirements.txt
fi

# Start API
echo "🚀 Starting Flask API..."
echo ""
cd "$(dirname "$0")"
python3 api/app.py

