"""
PyTorch Dataset for Content Moderation
"""
import os
import pandas as pd
from PIL import Image
import torch
from torch.utils.data import Dataset
from transformers import AutoTokenizer
import torchvision.transforms as transforms

class ModerationDataset(Dataset):
    def __init__(self, csv_path, images_dir, tokenizer_name='distilbert-base-uncased', max_length=128, transform=None):
        """
        Args:
            csv_path: Path to dataset.csv
            images_dir: Directory containing images
            tokenizer_name: HuggingFace tokenizer name
            max_length: Maximum sequence length for text
            transform: Image transforms
        """
        self.df = pd.read_csv(csv_path)
        self.images_dir = images_dir
        self.tokenizer = AutoTokenizer.from_pretrained(tokenizer_name)
        self.max_length = max_length
        
        # Label mapping
        self.label_to_idx = {'safe': 0, 'weapon': 1, 'alcohol': 2, 'drugs': 3}
        self.idx_to_label = {v: k for k, v in self.label_to_idx.items()}
        
        # Image transforms
        if transform is None:
            self.transform = transforms.Compose([
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
        else:
            self.transform = transform
    
    def __len__(self):
        return len(self.df)
    
    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        
        # Load image
        image_path = os.path.join(self.images_dir, row['image_path'].replace('images/', ''))
        try:
            image = Image.open(image_path).convert('RGB')
            image = self.transform(image)
        except Exception as e:
            # If image fails to load, create a black image
            image = torch.zeros(3, 224, 224)
        
        # Process text
        title = str(row.get('title', ''))
        description = str(row.get('description', ''))
        text = f"{title} {description}".strip()
        
        # Tokenize text
        encoded = self.tokenizer(
            text,
            max_length=self.max_length,
            padding='max_length',
            truncation=True,
            return_tensors='pt'
        )
        
        # Label
        label = self.label_to_idx.get(row['label'], 0)
        
        return {
            'image': image,
            'input_ids': encoded['input_ids'].squeeze(0),
            'attention_mask': encoded['attention_mask'].squeeze(0),
            'label': torch.tensor(label, dtype=torch.long),
            'text': text
        }
