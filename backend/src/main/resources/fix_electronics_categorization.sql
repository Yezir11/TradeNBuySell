-- Fix Electronics Category - Remove Bicycles and Other Misplaced Items
-- Bicycles should be in Sports, not Electronics

USE tradenbysell;

-- Step 1: Move bicycles from Electronics to Sports
UPDATE listings 
SET category = 'Sports'
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bbicycle\\b'
    OR LOWER(title) REGEXP '\\bbike\\b'
    OR LOWER(description) REGEXP '\\bbicycle\\b'
    OR LOWER(description) REGEXP '\\bbike\\b'
  );

-- Step 2: Move mattresses from Electronics to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bmattress\\b'
    OR LOWER(description) REGEXP '\\bmattress\\b'
  );

-- Verify what's left in Electronics that might be misplaced
SELECT 
  CASE 
    WHEN LOWER(title) LIKE '%cooler%' THEN 'Air Cooler'
    WHEN LOWER(title) LIKE '%monitor%' THEN 'Monitor'
    WHEN LOWER(title) LIKE '%headphone%' THEN 'Headphone'
    WHEN LOWER(title) LIKE '%phone%' THEN 'Phone'
    WHEN LOWER(title) LIKE '%laptop%' THEN 'Laptop'
    WHEN LOWER(title) LIKE '%camera%' THEN 'Camera'
    WHEN LOWER(title) LIKE '%tablet%' THEN 'Tablet'
    ELSE 'Other'
  END AS item_type,
  COUNT(*) as count
FROM listings 
WHERE category = 'Electronics' AND is_active = 1
GROUP BY item_type
ORDER BY count DESC;

-- Final distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

