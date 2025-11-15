#!/bin/bash
# Fix torchvision compatibility issue

echo "🔧 Fixing PyTorch/torchvision compatibility issue..."
echo ""

# Uninstall existing versions
echo "Step 1: Uninstalling existing PyTorch and torchvision..."
pip3 uninstall -y torch torchvision torchaudio 2>/dev/null

# Install compatible versions
echo ""
echo "Step 2: Installing compatible versions..."
echo "   This ensures PyTorch and torchvision are compatible..."

# Install PyTorch first (CPU version for Mac)
pip3 install torch torchvision torchaudio

# Verify installation
echo ""
echo "Step 3: Verifying installation..."
python3 -c "
import torch
import torchvision
print(f'✅ PyTorch: {torch.__version__}')
print(f'✅ torchvision: {torchvision.__version__}')
print(f'✅ Compatibility check passed!')
" || {
    echo "❌ Installation failed. Trying alternative method..."
    pip3 install torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2
}

echo ""
echo "✅ Fix complete! Try running the notebook again."




