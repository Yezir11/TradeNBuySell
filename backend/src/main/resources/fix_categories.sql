-- Fix Category Distribution
-- This script redistributes listings across the 7 frontend categories:
-- Electronics, Books, Furniture, Clothing, Sports, Stationery, Other

USE tradenbysell;

-- Step 1: Map Fashion → Clothing (28 listings)
UPDATE listings 
SET category = 'Clothing' 
WHERE category = 'Fashion' AND is_active = 1;

-- Step 2: Map Appliances → Electronics (60 listings - air coolers, etc.)
UPDATE listings 
SET category = 'Electronics' 
WHERE category = 'Appliances' AND is_active = 1;

-- Step 3: Identify and categorize Books (look for book-related keywords)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND (
    LOWER(title) LIKE '%book%' 
    OR LOWER(description) LIKE '%book%'
    OR LOWER(title) LIKE '%novel%'
    OR LOWER(description) LIKE '%novel%'
    OR LOWER(title) LIKE '%textbook%'
    OR LOWER(description) LIKE '%textbook%'
    OR LOWER(title) LIKE '%text book%'
    OR LOWER(description) LIKE '%text book%'
  )
  AND category != 'Books';

-- Step 4: Identify and categorize Stationery (pens, pencils, notebooks, etc.)
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
    OR LOWER(title) LIKE '%ruler%'
    OR LOWER(description) LIKE '%ruler%'
    OR LOWER(title) LIKE '%geometry box%'
    OR LOWER(description) LIKE '%geometry box%'
  )
  AND category != 'Stationery';

-- Step 5: Add more Books to reach ~60 (if needed)
-- Use a temporary table to store IDs
CREATE TEMPORARY TABLE IF NOT EXISTS temp_books_ids AS
SELECT listing_id 
FROM listings 
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) LIKE '%text%' 
    OR LOWER(title) LIKE '%guide%'
    OR LOWER(title) LIKE '%manual%'
    OR LOWER(description) LIKE '%study%'
    OR LOWER(description) LIKE '%reference%'
    OR LOWER(description) LIKE '%academic%'
  )
ORDER BY RAND()
LIMIT 60;

UPDATE listings 
SET category = 'Books'
WHERE listing_id IN (SELECT listing_id FROM temp_books_ids);

DROP TEMPORARY TABLE IF EXISTS temp_books_ids;

-- Step 6: Add more Stationery to reach ~60 (if needed)
CREATE TEMPORARY TABLE IF NOT EXISTS temp_stationery_ids AS
SELECT listing_id 
FROM listings 
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) LIKE '%case%' 
    OR LOWER(title) LIKE '%organizer%'
    OR LOWER(title) LIKE '%storage%'
    OR LOWER(title) LIKE '%bag%'
    OR LOWER(description) LIKE '%small%'
    OR LOWER(description) LIKE '%portable%'
  )
ORDER BY RAND()
LIMIT 60;

UPDATE listings 
SET category = 'Stationery'
WHERE listing_id IN (SELECT listing_id FROM temp_stationery_ids);

DROP TEMPORARY TABLE IF EXISTS temp_stationery_ids;

-- Step 7: Convert some items to "Other" category (miscellaneous items)
-- Target: ~60 items
CREATE TEMPORARY TABLE IF NOT EXISTS temp_other_ids AS
SELECT listing_id 
FROM listings 
WHERE category IN ('Electronics', 'Furniture') 
  AND is_active = 1 
  AND (
    LOWER(title) NOT LIKE '%book%'
    AND LOWER(title) NOT LIKE '%pen%'
    AND LOWER(title) NOT LIKE '%pencil%'
    AND LOWER(title) NOT LIKE '%monitor%'
    AND LOWER(title) NOT LIKE '%headphone%'
    AND LOWER(title) NOT LIKE '%chair%'
    AND LOWER(title) NOT LIKE '%table%'
    AND LOWER(title) NOT LIKE '%desk%'
    AND LOWER(title) NOT LIKE '%bicycle%'
    AND LOWER(title) NOT LIKE '%shoe%'
    AND LOWER(title) NOT LIKE '%cooler%'
    AND LOWER(title) NOT LIKE '%mattress%'
    AND LOWER(title) NOT LIKE '%bed%'
    AND LOWER(description) NOT LIKE '%book%'
    AND LOWER(description) NOT LIKE '%pen%'
    AND LOWER(description) NOT LIKE '%monitor%'
  )
ORDER BY RAND()
LIMIT 60;

UPDATE listings 
SET category = 'Other'
WHERE listing_id IN (SELECT listing_id FROM temp_other_ids);

DROP TEMPORARY TABLE IF EXISTS temp_other_ids;

-- Step 8: If Electronics still has too many (>140), move excess to Other
CREATE TEMPORARY TABLE IF NOT EXISTS temp_electronics_excess_ids AS
SELECT listing_id 
FROM listings 
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) NOT LIKE '%monitor%'
    AND LOWER(title) NOT LIKE '%headphone%'
    AND LOWER(title) NOT LIKE '%laptop%'
    AND LOWER(title) NOT LIKE '%phone%'
    AND LOWER(title) NOT LIKE '%tablet%'
    AND LOWER(title) NOT LIKE '%camera%'
    AND LOWER(title) NOT LIKE '%cooler%'
    AND LOWER(description) NOT LIKE '%monitor%'
    AND LOWER(description) NOT LIKE '%headphone%'
  )
ORDER BY RAND()
LIMIT 100;

UPDATE listings 
SET category = 'Other'
WHERE listing_id IN (SELECT listing_id FROM temp_electronics_excess_ids);

DROP TEMPORARY TABLE IF EXISTS temp_electronics_excess_ids;

-- Verify final distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;
