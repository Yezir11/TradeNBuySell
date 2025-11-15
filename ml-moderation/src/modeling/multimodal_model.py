"""
Multimodal Content Moderation Model
Combines Vision Transformer (ViT) for images and DistilBERT for text
"""
import torch
import torch.nn as nn
import timm
from transformers import AutoModel, AutoTokenizer

class MultimodalModerationModel(nn.Module):
    def __init__(self, num_classes=4, image_model_name='vit_base_patch16_224', text_model_name='distilbert-base-uncased', dropout=0.3):
        super(MultimodalModerationModel, self).__init__()
        
        # Image encoder: Vision Transformer
        self.image_encoder = timm.create_model(
            image_model_name,
            pretrained=True,
            num_classes=0,  # Remove classifier head
            global_pool=''
        )
        image_dim = self.image_encoder.num_features  # Usually 768 for ViT-Base
        
        # Text encoder: DistilBERT (using AutoModel for compatibility)
        self.text_encoder = AutoModel.from_pretrained(text_model_name)
        text_dim = self.text_encoder.config.dim  # 768 for DistilBERT
        
        # Feature fusion
        self.fusion_dim = image_dim + text_dim  # 768 + 768 = 1536
        
        # Classification head
        self.classifier = nn.Sequential(
            nn.Linear(self.fusion_dim, 512),
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
            images: Tensor of shape (batch_size, 3, 224, 224)
            text_inputs: Dict with 'input_ids' and 'attention_mask', each of shape (batch_size, seq_len)
        Returns:
            logits: Tensor of shape (batch_size, num_classes)
        """
        # Image encoding
        if images is not None:
            image_features = self.image_encoder.forward_features(images)
            # Global average pooling for ViT
            if len(image_features.shape) == 3:  # (batch, num_patches, dim)
                image_features = image_features.mean(dim=1)  # Global average pooling
            elif len(image_features.shape) == 4:  # (batch, channels, H, W)
                image_features = image_features.mean(dim=[2, 3])  # Global average pooling
        else:
            # If no image, use zero features
            batch_size = text_inputs['input_ids'].shape[0]
            image_features = torch.zeros(batch_size, 768).to(text_inputs['input_ids'].device)
        
        # Text encoding
        if text_inputs is not None:
            text_outputs = self.text_encoder(
                input_ids=text_inputs['input_ids'],
                attention_mask=text_inputs['attention_mask']
            )
            # Use [CLS] token embedding (first token)
            text_features = text_outputs.last_hidden_state[:, 0, :]  # (batch_size, 768)
        else:
            # If no text, use zero features
            batch_size = image_features.shape[0]
            text_features = torch.zeros(batch_size, 768).to(image_features.device)
        
        # Concatenate features
        combined_features = torch.cat([image_features, text_features], dim=1)  # (batch_size, 1536)
        
        # Classification
        logits = self.classifier(combined_features)
        
        return logits
