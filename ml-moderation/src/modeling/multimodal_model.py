"""
Multimodal Moderation Model
Combines Vision Transformer (ViT) for images and DistilBERT for text
"""
import torch
import torch.nn as nn
from transformers import AutoModel, AutoTokenizer
import torchvision.models as models


class MultimodalModerationModel(nn.Module):
    """
    Multimodal model combining ViT for image processing and DistilBERT for text processing
    """
    def __init__(self, num_classes=4, image_model_name='vit_base_patch16_224', 
                 text_model_name='distilbert-base-uncased', dropout=0.3):
        super(MultimodalModerationModel, self).__init__()
        
        self.num_classes = num_classes
        
        # Image encoder (ViT)
        if image_model_name == 'vit_base_patch16_224':
            # Use timm for ViT if available, otherwise use torchvision
            try:
                import timm
                self.image_encoder = timm.create_model('vit_base_patch16_224', pretrained=True, num_classes=0)
                image_dim = 768
            except ImportError:
                # Fallback to torchvision ViT
                try:
                    self.image_encoder = models.vit_b_16(pretrained=True)
                    # Remove the classifier head
                    self.image_encoder.heads = nn.Identity()
                    image_dim = 768
                except:
                    # Fallback to ResNet if ViT not available
                    self.image_encoder = models.resnet50(pretrained=True)
                    self.image_encoder.fc = nn.Identity()
                    image_dim = 2048
        else:
            # Use ResNet as fallback
            self.image_encoder = models.resnet50(pretrained=True)
            self.image_encoder.fc = nn.Identity()
            image_dim = 2048
        
        # Text encoder (DistilBERT)
        self.text_encoder = AutoModel.from_pretrained(text_model_name)
        text_dim = self.text_encoder.config.dim  # DistilBERT hidden size is 768
        
        # Feature fusion
        # Combine image and text features
        fusion_dim = image_dim + text_dim
        
        # Classification head
        self.classifier = nn.Sequential(
            nn.Dropout(dropout),
            nn.Linear(fusion_dim, 512),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(256, num_classes)
        )
        
    def forward(self, images, text_inputs):
        """
        Forward pass
        
        Args:
            images: Tensor of shape (batch_size, 3, 224, 224) or None
            text_inputs: Dict with 'input_ids' and 'attention_mask' or None
        
        Returns:
            Logits of shape (batch_size, num_classes)
        """
        batch_size = None
        
        # Extract image features
        if images is not None:
            image_features = self.image_encoder(images)
            if len(image_features.shape) > 2:
                # If output is not flattened, average pool
                image_features = image_features.mean(dim=1)
            batch_size = image_features.shape[0]
        else:
            # If no image, use zero features
            image_features = None
        
        # Extract text features
        if text_inputs is not None:
            text_outputs = self.text_encoder(
                input_ids=text_inputs['input_ids'],
                attention_mask=text_inputs['attention_mask']
            )
            # Use [CLS] token embedding (first token)
            text_features = text_outputs.last_hidden_state[:, 0, :]
            if batch_size is None:
                batch_size = text_features.shape[0]
        else:
            # If no text, use zero features
            text_features = None
        
        # Handle missing inputs
        if image_features is None and text_features is None:
            raise ValueError("At least one of images or text_inputs must be provided")
        
        if image_features is None:
            # Only text
            image_features = torch.zeros(batch_size, 768, device=text_features.device)
        elif text_features is None:
            # Only image
            text_features = torch.zeros(batch_size, 768, device=image_features.device)
        
        # Ensure dimensions match
        if image_features.shape[1] != 768:
            # Project to 768 if needed (for ResNet fallback)
            if not hasattr(self, 'image_projection'):
                self.image_projection = nn.Linear(image_features.shape[1], 768).to(image_features.device)
            image_features = self.image_projection(image_features)
        
        # Concatenate features
        combined_features = torch.cat([image_features, text_features], dim=1)
        
        # Classification
        logits = self.classifier(combined_features)
        
        return logits

