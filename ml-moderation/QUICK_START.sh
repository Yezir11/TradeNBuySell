#!/bin/bash
# Quick Start Script for Content Moderation Pipeline

echo "🚀 Content Moderation Pipeline - Quick Start"
echo "=============================================="
echo ""

# Step 1: Check Python
echo "Step 1: Checking Python..."
python3 --version || { echo "❌ Python 3 not found!"; exit 1; }
echo "✅ Python found"
echo ""

# Step 2: Check dataset
echo "Step 2: Checking dataset..."
if [ ! -f "data/dataset.csv" ]; then
    echo "⚠️  Dataset not found. Building dataset..."
    python3 scripts/build_dataset_from_scripts.py
else
    echo "✅ Dataset found"
fi
echo ""

# Step 3: Check dependencies
echo "Step 3: Checking dependencies..."
if ! python3 -c "import torch" 2>/dev/null; then
    echo "⚠️  PyTorch not found. Installing dependencies..."
    pip3 install -r requirements.txt
else
    echo "✅ Dependencies installed"
fi
echo ""

# Step 4: Start Jupyter
echo "Step 4: Starting Jupyter Notebook..."
echo ""
echo "📓 Opening notebook: notebooks/moderation_pipeline.ipynb"
echo ""
echo "💡 Instructions:"
echo "   1. Run all cells sequentially"
echo "   2. Training will take 1.5-2 hours on CPU, 6-8 min on GPU"
echo "   3. Monitor progress bars"
echo "   4. Model will be saved automatically"
echo ""
echo "Starting Jupyter..."
jupyter notebook notebooks/moderation_pipeline.ipynb
