# 🔧 Fix: TensorFlow Import Error

## Error
```
NotFoundError: dlopen(.../libmetal_plugin.dylib, ...): Library not loaded: @rpath/_pywrap_tensorflow_internal.so
```

## Cause
- Transformers library tries to import TensorFlow (for optional features)
- TensorFlow is installed but has incompatible plugins for Mac ARM
- We're using PyTorch, so TensorFlow isn't needed

## Solution Applied

1. **Uninstalled TensorFlow** - Removed tensorflow and tensorflow-macos packages
2. **Set environment variables** - Added to notebook before imports:
   - `TF_CPP_MIN_LOG_LEVEL='3'` - Suppress TensorFlow warnings
   - `DISABLE_TF='1'` - Signal to disable TensorFlow
   - `TOKENIZERS_PARALLELISM='false'` - Avoid tokenizer warnings

## Why This Works

Transformers has optional TensorFlow support. By:
- Uninstalling TensorFlow
- Setting environment variables before importing transformers
- Transformers will skip TensorFlow imports and work with PyTorch only

## Verification

After restarting the kernel, transformers should import without trying to load TensorFlow.

## Alternative (If Issues Persist)

If you still see TensorFlow-related errors, you can also:

```python
import os
os.environ['TF_DISABLE'] = '1'
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

# Then import transformers
from transformers import AutoModel, AutoTokenizer
```

## Note

This project uses **PyTorch only**. TensorFlow is not required for:
- Model training
- Inference
- Explainability (Grad-CAM, SHAP)
- API serving

All functionality works with PyTorch.




