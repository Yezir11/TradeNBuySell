-- Fix Category Distribution - Proper Version
-- This script redistributes listings across the 7 frontend categories:
-- Electronics, Books, Furniture, Clothing, Sports, Stationery, Other

USE tradenbysell;

-- Step 1: Reset categories to a known state
-- First, let's categorize based on titles/descriptions more carefully

-- Step 2: Identify Books (only actual books)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND (
    (LOWER(title) LIKE '%book%' AND LOWER(title) NOT LIKE '%notebook%')
    OR (LOWER(description) LIKE '%book%' AND LOWER(description) NOT LIKE '%notebook%')
    OR LOWER(title) LIKE '%novel%'
    OR LOWER(description) LIKE '%novel%'
    OR LOWER(title) LIKE '%textbook%'
    OR LOWER(description) LIKE '%textbook%'
  );

-- Step 3: Identify Stationery (only actual stationery items)
UPDATE listings 
SET category = 'Stationery'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%pen%'
    OR LOWER(description) LIKE '%pen%'
    OR LOWER(title) LIKE '%pencil%'
    OR LOWER(description) LIKE '%pencil%'
    OR LOWER(title) LIKE '%notebook%'
    OR LOWER(description) LIKE '%notebook%'
    OR LOWER(title) LIKE '%stationery%'
    OR LOWER(description) LIKE '%stationery%'
    OR LOWER(title) LIKE '%eraser%'
    OR LOWER(description) LIKE '%eraser%'
  )
  AND category != 'Books';

-- Step 4: Identify Clothing (shoes, fashion items)
UPDATE listings 
SET category = 'Clothing'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%shoe%'
    OR LOWER(title) LIKE '%sneaker%'
    OR LOWER(description) LIKE '%shoe%'
    OR LOWER(description) LIKE '%sneaker%'
    OR LOWER(title) LIKE '%clothing%'
    OR LOWER(description) LIKE '%clothing%'
  )
  AND category NOT IN ('Books', 'Stationery');

-- Step 5: Identify Sports (bicycles, sports equipment)
UPDATE listings 
SET category = 'Sports'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%bicycle%'
    OR LOWER(title) LIKE '%bike%'
    OR LOWER(description) LIKE '%bicycle%'
    OR LOWER(description) LIKE '%bike%'
    OR LOWER(title) LIKE '%sports%'
    OR LOWER(description) LIKE '%sports%'
  )
  AND category NOT IN ('Books', 'Stationery', 'Clothing');

-- Step 6: Identify Furniture (chairs, tables, mattresses, beds)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%chair%'
    OR LOWER(title) LIKE '%table%'
    OR LOWER(title) LIKE '%desk%'
    OR LOWER(title) LIKE '%mattress%'
    OR LOWER(title) LIKE '%bed%'
    OR LOWER(description) LIKE '%chair%'
    OR LOWER(description) LIKE '%table%'
    OR LOWER(description) LIKE '%desk%'
    OR LOWER(description) LIKE '%mattress%'
    OR LOWER(description) LIKE '%bed%'
  )
  AND category NOT IN ('Books', 'Stationery', 'Clothing', 'Sports');

-- Step 7: Identify Electronics (monitors, headphones, coolers, etc.)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%monitor%'
    OR LOWER(title) LIKE '%headphone%'
    OR LOWER(title) LIKE '%cooler%'
    OR LOWER(title) LIKE '%laptop%'
    OR LOWER(title) LIKE '%phone%'
    OR LOWER(title) LIKE '%tablet%'
    OR LOWER(title) LIKE '%camera%'
    OR LOWER(description) LIKE '%monitor%'
    OR LOWER(description) LIKE '%headphone%'
    OR LOWER(description) LIKE '%cooler%'
  )
  AND category NOT IN ('Books', 'Stationery', 'Clothing', 'Sports', 'Furniture');

-- Step 8: Everything else goes to "Other"
UPDATE listings 
SET category = 'Other'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Books', 'Furniture', 'Clothing', 'Sports', 'Stationery');

-- Verify final distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

