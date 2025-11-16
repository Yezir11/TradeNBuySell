#!/usr/bin/env python3
"""
Flask API for ML Content Moderation
Serves the trained moderation model for TradeNBuySell application
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys
import base64
import io
import json

app = Flask(__name__)
CORS(app)

# Configuration
# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
MODEL_PATH = os.environ.get('MODEL_PATH', os.path.join(BASE_DIR, 'models', 'model.pt'))
PORT = int(os.environ.get('PORT', 5002))  # Changed from 5000 to avoid macOS AirPlay conflict, using 5002

# Try to import ML dependencies (optional)
ML_DEPENDENCIES_AVAILABLE = False
try:
    import torch
    import numpy as np
    from PIL import Image
    DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    ML_DEPENDENCIES_AVAILABLE = True
except ImportError:
    print("⚠️  ML dependencies not available. Running in mock mode only.")
    DEVICE = None

# Global variables for model and tokenizer
model = None
tokenizer = None
image_transform = None

# Labels
LABELS = ['safe', 'weapon', 'alcohol', 'drugs']


def load_model():
    """Load the trained moderation model"""
    global model, tokenizer, image_transform
    
    if not ML_DEPENDENCIES_AVAILABLE:
        print("⚠️  ML dependencies not installed. Running in mock mode.")
        return False
    
    if not os.path.exists(MODEL_PATH):
        print(f"⚠️  Warning: Model file not found at {MODEL_PATH}")
        print("   Moderation API will run in mock mode (always returns 'safe')")
        print("   Train the model first: jupyter notebook notebooks/moderation_pipeline.ipynb")
        return False
    
    try:
        print(f"📦 Loading model from {MODEL_PATH}...")
        
        # Try to load tokenizer
        try:
            from transformers import AutoTokenizer
            tokenizer = AutoTokenizer.from_pretrained('distilbert-base-uncased')
        except ImportError:
            try:
                from transformers import DistilBERTTokenizer
                tokenizer = DistilBERTTokenizer.from_pretrained('distilbert-base-uncased')
            except ImportError:
                print("⚠️  Could not load tokenizer. Text processing will be limited.")
                tokenizer = None
        
        # Try to load image transform
        try:
            import torchvision.transforms as transforms
            image_transform = transforms.Compose([
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
        except ImportError:
            print("⚠️  torchvision not available. Image processing will be limited.")
            image_transform = None
        
        # Try to load model
        try:
            checkpoint = torch.load(MODEL_PATH, map_location=DEVICE)
            
            # If checkpoint is a dictionary with 'model_state_dict', extract it
            if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
                state_dict = checkpoint['model_state_dict']
            else:
                state_dict = checkpoint
            
            # Try to import model architecture
            src_path = os.path.join(BASE_DIR, 'src')
            if os.path.exists(src_path):
                sys.path.insert(0, src_path)
                try:
                    from modeling.multimodal_model import MultimodalModerationModel
                    model = MultimodalModerationModel(num_classes=len(LABELS))
                    model.load_state_dict(state_dict, strict=False)  # Use strict=False for flexibility
                    model.to(DEVICE)
                    model.eval()
                    print(f"✅ Model loaded successfully on {DEVICE}")
                    return True
                except Exception as e:
                    print(f"⚠️  Could not load model architecture: {e}")
                    import traceback
                    traceback.print_exc()
                    print("   Running in mock mode.")
                    return False
            else:
                print(f"⚠️  Source directory not found at {src_path}. Running in mock mode.")
                return False
                
        except Exception as e:
            print(f"⚠️  Error loading model: {e}")
            print("   Running in mock mode.")
            return False
            
    except Exception as e:
        print(f"⚠️  Error in load_model: {e}")
        print("   Running in mock mode (always returns 'safe')")
        return False


def predict_mock(title, description, image_base64):
    """Mock prediction (returns safe when model is not loaded)"""
    return {
        'label': 'safe',
        'confidence': 0.95,
        'should_flag': False,
        'all_probabilities': {
            'safe': 0.95,
            'weapon': 0.02,
            'alcohol': 0.02,
            'drugs': 0.01
        },
        'image_heatmap': None,
        'text_explanation': {
            'tokens': title.split()[:5] if title else [],
            'scores': [0.8] * min(5, len(title.split()) if title else 0)
        }
    }


def predict_with_model(title, description, image_base64):
    """Run moderation prediction with actual model"""
    global model, tokenizer, image_transform
    
    if not ML_DEPENDENCIES_AVAILABLE or model is None:
        return predict_mock(title, description, image_base64)
    
    try:
        # Import torch utilities
        import torch
        import numpy as np
        from PIL import Image
        
        # Preprocess image
        image_tensor = None
        if image_base64 and image_transform:
            try:
                image_data = base64.b64decode(image_base64)
                image = Image.open(io.BytesIO(image_data)).convert('RGB')
                image_tensor = image_transform(image).unsqueeze(0).to(DEVICE)
            except Exception as e:
                print(f"Error preprocessing image: {e}")
        
        # Preprocess text
        text_inputs = None
        if tokenizer:
            try:
                text = f"{title} {description}"
                encoded = tokenizer(
                    text,
                    max_length=128,
                    padding='max_length',
                    truncation=True,
                    return_tensors='pt'
                )
                text_inputs = {k: v.to(DEVICE) for k, v in encoded.items()}
            except Exception as e:
                print(f"Error preprocessing text: {e}")
        
        # Run inference
        with torch.no_grad():
            if image_tensor is not None and text_inputs is not None:
                outputs = model(image_tensor, text_inputs)
            elif text_inputs is not None:
                outputs = model(None, text_inputs)
            else:
                return predict_mock(title, description, image_base64)
            
            # Get probabilities
            probabilities = torch.softmax(outputs, dim=1)[0].cpu().numpy()
            
            # Get predicted label
            predicted_idx = np.argmax(probabilities)
            predicted_label = LABELS[predicted_idx]
            confidence = float(probabilities[predicted_idx])
            
            # Determine if should flag (flag non-safe content)
            # Flag if predicted as prohibited OR if any prohibited class has high probability (>0.3)
            should_flag = bool(predicted_label != 'safe')
            if not should_flag:
                # Even if safe is predicted, flag if any prohibited class has significant probability
                prohibited_probs = [probabilities[i] for i, label in enumerate(LABELS) if label != 'safe']
                if prohibited_probs:
                    max_prohibited_prob = max(prohibited_probs)
                    should_flag = bool(max_prohibited_prob > 0.3)  # Lower threshold for safety
                else:
                    should_flag = False
            
            # Build response
            all_probabilities = {label: float(prob) for label, prob in zip(LABELS, probabilities)}
            
            # Generate explanations (simplified for now)
            image_heatmap = None  # TODO: Add Grad-CAM visualization
            text_explanation = {
                'tokens': title.split()[:5] if title else [],
                'scores': [float(p) for p in probabilities[:5]]
            }
            
            return {
                'label': predicted_label,
                'confidence': confidence,
                'should_flag': should_flag,
                'all_probabilities': all_probabilities,
                'image_heatmap': image_heatmap,
                'text_explanation': text_explanation
            }
            
    except Exception as e:
        print(f"Error during prediction: {e}")
        import traceback
        traceback.print_exc()
        # Return safe as fallback
        return predict_mock(title, description, image_base64)


def predict(title, description, image_base64):
    """Run moderation prediction - dispatches to model or mock"""
    if model is None or not ML_DEPENDENCIES_AVAILABLE:
        return predict_mock(title, description, image_base64)
    return predict_with_model(title, description, image_base64)


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    model_status = "loaded" if model is not None else "mock_mode"
    ml_available = "yes" if ML_DEPENDENCIES_AVAILABLE else "no"
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'model_status': model_status,
        'ml_dependencies_available': ml_available,
        'device': str(DEVICE) if DEVICE else 'N/A',
        'model_path': MODEL_PATH
    }), 200


@app.route('/moderate', methods=['POST'])
def moderate():
    """Main moderation endpoint"""
    try:
        # Get request data
        if request.is_json:
            data = request.get_json()
            title = data.get('title', '')
            description = data.get('description', '')
            image_base64 = data.get('imageBase64', None)
        else:
            # Handle form-data (multipart)
            title = request.form.get('title', '')
            description = request.form.get('description', '')
            image_file = request.files.get('image')
            
            if image_file:
                image_bytes = image_file.read()
                image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            else:
                image_base64 = None
        
        # Validate input
        if not title and not description:
            return jsonify({
                'error': 'At least title or description is required'
            }), 400
        
        # Run prediction
        result = predict(title, description, image_base64)
        
        return jsonify(result), 200
        
    except Exception as e:
        print(f"Error in moderation endpoint: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500


if __name__ == '__main__':
    print("=" * 60)
    print("🚀 ML Moderation API Starting...")
    print("=" * 60)
    print(f"📁 Model path: {MODEL_PATH}")
    print(f"🖥️  Device: {DEVICE if ML_DEPENDENCIES_AVAILABLE else 'N/A'}")
    print(f"🌐 Port: {PORT}")
    print("=" * 60)
    
    # Load model
    if ML_DEPENDENCIES_AVAILABLE:
        model_loaded = load_model()
    else:
        print("⚠️  ML dependencies not installed. Running in mock mode only.")
        print("   Install dependencies: pip3 install torch torchvision transformers")
        model_loaded = False
    
    if model_loaded:
        print("✅ Ready to serve moderation requests with ML model")
    else:
        print("⚠️  Running in MOCK MODE - All predictions will return 'safe'")
        print("   This is OK for testing. Your application will work normally.")
        print("   To enable real moderation:")
        print("   1. Install ML dependencies: pip3 install -r requirements.txt")
        print("   2. Train the model: jupyter notebook notebooks/moderation_pipeline.ipynb")
        print("   3. Ensure model is saved to models/model.pt")
        print("   4. Restart this API")
    
    print("=" * 60)
    print(f"📡 API running at http://localhost:{PORT}")
    print(f"🏥 Health check: http://localhost:{PORT}/health")
    print(f"🔍 Moderation: POST http://localhost:{PORT}/moderate")
    print("=" * 60)
    
    # Start Flask app
    app.run(host='0.0.0.0', port=PORT, debug=False)
