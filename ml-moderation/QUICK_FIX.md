# ⚡ Quick Fix: torchvision RuntimeError

## The Problem
```
RuntimeError: operator torchvision::nms does not exist
```

This happens when PyTorch and torchvision versions don't match.

## The Solution

### Step 1: Stop Jupyter Kernel
In your Jupyter notebook:
- Click **Kernel → Interrupt** (or **Restart Kernel**)

### Step 2: Fix Versions (Run in Terminal)

```bash
# Uninstall incompatible versions
pip3 uninstall -y torch torchvision torchaudio

# Reinstall compatible versions
pip3 install torch torchvision torchaudio
```

### Step 3: Restart Jupyter Kernel
- In Jupyter: **Kernel → Restart Kernel**
- Or close and reopen the notebook

### Step 4: Test the Fix
Run this in a new cell:
```python
import torch
import torchvision.transforms as transforms
print("✅ Success! Versions:", torch.__version__, torchvision.__version__)
```

## If That Doesn't Work

Try installing specific versions:
```bash
pip3 uninstall -y torch torchvision torchaudio
pip3 install torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2
```

## Why This Happens

- PyTorch and torchvision must be compatible
- Different install methods can cause mismatches
- Python 3.12 may need specific versions

## Prevention

Always install from requirements.txt:
```bash
pip3 install -r requirements.txt
```

This ensures compatible versions.




