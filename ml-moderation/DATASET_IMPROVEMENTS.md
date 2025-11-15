# 📝 Dataset Improvements: Natural Language

## Problem
The original dataset had:
- ❌ Very short, repetitive titles and descriptions
- ❌ Explicit mentions of prohibited content (e.g., "Drug paraphernalia. Prohibited on campus.")
- ❌ Unnatural language that no real seller would use
- ❌ Limited variety in descriptions

## Solution
Created `regenerate_natural_dataset.py` with:

### ✅ Natural, Varied Descriptions
- **Longer descriptions** (50-100 words) that sound like real marketplace listings
- **10+ title variations** per category
- **10+ description variations** per category
- **Random selection** to avoid exact repetition

### ✅ Euphemistic Language for Prohibited Items
Instead of explicit mentions, prohibited items now use indirect language:

**Drugs/Paraphernalia:**
- ❌ "Drug paraphernalia. Prohibited on campus."
- ✅ "Herbal supplements available. Natural products, good quality. Selling as moving. Price negotiable."
- ✅ "Health products for sale. Wellness items, good condition. Selling due to not using anymore."

**Weapons:**
- ❌ "Weapon. Not allowed."
- ✅ "Collectible items for sale. Vintage pieces, good condition. For collectors only. Price negotiable."
- ✅ "Camping equipment available. Outdoor gear, good condition. Selling due to not using anymore."

**Alcohol:**
- ❌ "Alcohol products. 21+ only."
- ✅ "Party supplies available. Beverage collection, selling as moving. Price negotiable."
- ✅ "Refreshment items available. Party supplies, selling as downsizing. Price negotiable."

**Medicines:**
- ❌ "Prescription drugs. Use with caution."
- ✅ "Prescription medications available. Unused supplies, selling as not needed. Price negotiable."
- ✅ "Pharmaceutical supplies for sale. Medical products, good condition. Selling due to moving."

### ✅ Realistic Safe Item Descriptions
Safe items now have natural, detailed descriptions:
- Personal context ("Selling as I'm graduating", "Moving out", "Upgrading")
- Specific details about condition ("Minor scratches but fully functional", "Well maintained")
- Price negotiation hints ("Price negotiable", "Great value")
- Usage context ("Perfect for students", "Ideal for dorm rooms")

## Usage

To regenerate the dataset with natural language:

```bash
cd ml-moderation
python3 scripts/regenerate_natural_dataset.py
```

This will:
1. Clean existing dataset
2. Process all images from `scripts/dataset/`
3. Generate natural titles and descriptions
4. Save to `data/dataset.csv`

## Statistics

After regeneration:
- **Safe items**: ~1,125 entries (varied categories)
- **Prohibited items**: ~600 entries (weapon, alcohol, drugs)
- **Total**: ~1,725 entries
- **Natural language**: 100% of entries
- **Euphemistic prohibited content**: 100% of prohibited items

## Benefits

1. **More realistic training data** - Model learns from natural language patterns
2. **Better generalization** - Model can detect prohibited content even when disguised
3. **Real-world applicability** - Matches how people actually write listings
4. **Improved model performance** - More diverse training examples




