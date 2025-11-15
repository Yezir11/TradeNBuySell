# 📝 Enhanced Text Processing Explanation

## How Text-Based Detection Works

### Current Implementation (Enhanced Model)

The enhanced model processes title and description **separately** with advanced features:

## 1. ✅ Title Weighting (70% vs 30%)

**Why?** Titles are typically more informative and concise.

**How it works:**
- Title and description are encoded separately using DistilBERT
- Title features get **70% weight**
- Description features get **30% weight**
- Final text representation: `0.7 × title_features + 0.3 × desc_features`

**Example:**
```
Title: "Used Bicycle for Sale"
Description: "Great condition, well maintained, perfect for campus..."

→ Title contributes 70% to the final decision
→ Description contributes 30%
```

## 2. ✅ Longer Text Support (256 tokens)

**Why?** Descriptions can be long and detailed.

**How it works:**
- **Title**: Up to 64 tokens (sufficient for most titles)
- **Description**: Up to 192 tokens (handles longer descriptions)
- **Total**: 256 tokens (increased from 128)

**Token Allocation:**
```
Title:     [0-64 tokens]   ← More important, gets priority
Description: [0-192 tokens] ← Can be longer
```

## 3. ✅ Explicit Keyword Detection

**Why?** Certain words strongly indicate prohibited content.

**How it works:**
- **Keyword Vocabulary** built into the model:
  - **Weapons**: weapon, knife, gun, sword, blade, firearm, pistol, rifle...
  - **Alcohol**: alcohol, beer, wine, whiskey, vodka, rum, liquor...
  - **Drugs**: drug, medicine, pill, cannabis, marijuana, vape, cigarette...

- **Keyword Attention Mechanism**:
  - Multi-head attention focuses on keyword positions
  - Enhances text features when keywords are detected
  - Helps model identify prohibited content more accurately

**Example:**
```
Title: "Vintage Knife Collection"
→ Keyword "knife" detected
→ Attention mechanism focuses on this token
→ Model gets stronger signal for "weapon" class
```

## 4. ✅ Order-Aware Processing

**Why?** Title → Description order matters semantically.

**How it works:**
- **Separate Encoders**: 
  - `title_encoder`: DistilBERT for title only
  - `desc_encoder`: DistilBERT for description only
  
- **Order Preservation**:
  - Title is processed first (more important)
  - Description follows (supporting context)
  - Model understands the hierarchy

- **Separate Representations**:
  - Title features: Semantic meaning of title
  - Description features: Semantic meaning of description
  - Combined intelligently with weights

## Architecture Flow

```
Input:
├── Image (224×224)
├── Title: "Used Bicycle" (64 tokens max)
└── Description: "Great condition..." (192 tokens max)

Processing:
1. Image → ViT → Image Features (768-dim)
2. Title → DistilBERT → Title Features (768-dim) [70% weight]
3. Description → DistilBERT → Desc Features (768-dim) [30% weight]
4. Keyword Detection → Identify prohibited keywords
5. Keyword Attention → Enhance features based on keywords
6. Weighted Fusion → Combine title (70%) + desc (30%)
7. Text Fusion → Combine title and desc representations
8. Multimodal Fusion → Combine image + text
9. Classification → Output 4 class probabilities
```

## Benefits

1. **Better Title Understanding**: 
   - Titles are weighted more heavily
   - Captures key information immediately

2. **Longer Descriptions**: 
   - Can handle detailed product descriptions
   - No information loss from truncation

3. **Keyword Awareness**: 
   - Explicitly detects prohibited keywords
   - Attention mechanism focuses on important words

4. **Order Preservation**: 
   - Maintains semantic structure
   - Title → Description hierarchy respected

## Example Workflow

**Input:**
- Title: "Vintage Knife Collection"
- Description: "Beautiful collection of vintage knives, perfect for collectors. All items are decorative only."

**Processing:**
1. Title encoded: "Vintage Knife Collection" → Title features
2. Description encoded: "Beautiful collection..." → Desc features
3. Keyword detected: "knife" → Keyword attention activated
4. Weighted fusion: Title (70%) + Desc (30%)
5. Keyword attention enhances "knife" signal
6. Model predicts: `weapon` with high confidence

## Comparison: Old vs Enhanced

| Feature | Old Model | Enhanced Model |
|---------|----------|----------------|
| Text Processing | Combined title+desc | Separate title/desc |
| Max Length | 128 tokens | 256 tokens (64+192) |
| Title Weight | Equal (50%) | Higher (70%) |
| Keyword Detection | Implicit | Explicit + Attention |
| Order Awareness | Lost | Preserved |

## Implementation Files

- **Model**: `src/modeling/enhanced_multimodal_model.py`
- **Dataset**: `src/modeling/enhanced_dataset.py`
- **Notebook**: `notebooks/moderation_pipeline.ipynb` (updated)

## Usage

The notebook automatically uses the enhanced model. Just run all cells - everything is configured!




