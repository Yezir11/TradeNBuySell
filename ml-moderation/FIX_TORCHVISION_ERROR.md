# 🔧 Fix: torchvision RuntimeError

## Error
```
RuntimeError: operator torchvision::nms does not exist
```

## Cause
Version incompatibility between PyTorch and torchvision.

## Solution

### Quick Fix (Recommended)

Run this command:
```bash
cd /Users/vaibhavvyas/Desktop/SEMProject/ml-moderation
./fix_torchvision_issue.sh
```

Or manually:
```bash
# Uninstall incompatible versions
pip3 uninstall -y torch torchvision torchaudio

# Reinstall compatible versions
pip3 install torch torchvision torchaudio

# Verify
python3 -c "import torch; import torchvision; print(f'PyTorch: {torch.__version__}'); print(f'torchvision: {torchvision.__version__}')"
```

### Alternative: Install Specific Compatible Versions

If the above doesn't work, install specific versions:

```bash
pip3 uninstall -y torch torchvision torchaudio
pip3 install torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2
```

### For Mac with Apple Silicon (M1/M2/M3)

If you have Apple Silicon, use:
```bash
pip3 uninstall -y torch torchvision torchaudio
pip3 install torch torchvision torchaudio
```

PyTorch will automatically install the correct version for your system.

## Verify Fix

After reinstalling, test:
```python
import torch
import torchvision.transforms as transforms
print("✅ Import successful!")
```

## Prevention

The `requirements.txt` has been updated to ensure compatible versions. Always install from requirements.txt:
```bash
pip3 install -r requirements.txt
```




