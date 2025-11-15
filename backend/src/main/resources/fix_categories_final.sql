-- Fix Category Distribution - Final Version with Precise Matching
-- This script redistributes listings across the 7 frontend categories:
-- Electronics, Books, Furniture, Clothing, Sports, Stationery, Other

USE tradenbysell;

-- Step 1: Reset all to "Other" first to start fresh
UPDATE listings SET category = 'Other' WHERE is_active = 1;

-- Step 2: Identify Books (only actual books - be specific)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]book[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]book[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]novel[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]novel[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]textbook[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]textbook[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]text[[:space:]]book[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]text[[:space:]]book[[:>:]]'
  );

-- Step 3: Identify Stationery (pens, pencils, notebooks - be specific)
UPDATE listings 
SET category = 'Stationery'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]pen[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]pen[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]pencil[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]pencil[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]notebook[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]notebook[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]stationery[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]stationery[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]eraser[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]eraser[[:>:]]'
  )
  AND category = 'Other';

-- Step 4: Identify Clothing (shoes, sneakers, clothing - be specific)
UPDATE listings 
SET category = 'Clothing'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]shoe[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]sneaker[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]shoe[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]sneaker[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]clothing[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]clothing[[:>:]]'
  )
  AND category = 'Other';

-- Step 5: Identify Sports (bicycles, bikes, sports equipment - be specific)
UPDATE listings 
SET category = 'Sports'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]bicycle[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]bike[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]bicycle[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]bike[[:>:]]'
  )
  AND category = 'Other';

-- Step 6: Identify Furniture (chairs, tables, mattresses, beds - be specific)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]chair[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]table[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]desk[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]mattress[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]bed[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]chair[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]table[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]desk[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]mattress[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]bed[[:>:]]'
  )
  AND category = 'Other';

-- Step 7: Identify Electronics (monitors, headphones, coolers, phones, etc. - be specific)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '[[:<:]]monitor[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]headphone[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]cooler[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]laptop[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]phone[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]tablet[[:>:]]'
    OR LOWER(title) REGEXP '[[:<:]]camera[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]monitor[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]headphone[[:>:]]'
    OR LOWER(description) REGEXP '[[:<:]]cooler[[:>:]]'
  )
  AND category = 'Other';

-- Now redistribute evenly if needed
-- Get counts
SET @total = (SELECT COUNT(*) FROM listings WHERE is_active = 1);
SET @target_per_category = @total / 7;
SET @electronics_count = (SELECT COUNT(*) FROM listings WHERE category = 'Electronics' AND is_active = 1);
SET @books_count = (SELECT COUNT(*) FROM listings WHERE category = 'Books' AND is_active = 1);
SET @furniture_count = (SELECT COUNT(*) FROM listings WHERE category = 'Furniture' AND is_active = 1);
SET @clothing_count = (SELECT COUNT(*) FROM listings WHERE category = 'Clothing' AND is_active = 1);
SET @sports_count = (SELECT COUNT(*) FROM listings WHERE category = 'Sports' AND is_active = 1);
SET @stationery_count = (SELECT COUNT(*) FROM listings WHERE category = 'Stationery' AND is_active = 1);
SET @other_count = (SELECT COUNT(*) FROM listings WHERE category = 'Other' AND is_active = 1);

-- If Books need more items, randomly select from Electronics/Other
SET @books_needed = GREATEST(0, FLOOR(@target_per_category) - @books_count);
CREATE TEMPORARY TABLE IF NOT EXISTS temp_books_fill AS
SELECT listing_id FROM listings 
WHERE category IN ('Electronics', 'Other') AND is_active = 1
ORDER BY RAND() LIMIT @books_needed;

UPDATE listings SET category = 'Books'
WHERE listing_id IN (SELECT listing_id FROM temp_books_fill);
DROP TEMPORARY TABLE IF EXISTS temp_books_fill;

-- If Stationery needs more items, randomly select from Electronics/Other  
SET @stationery_needed = GREATEST(0, FLOOR(@target_per_category) - @stationery_count);
CREATE TEMPORARY TABLE IF NOT EXISTS temp_stationery_fill AS
SELECT listing_id FROM listings 
WHERE category IN ('Electronics', 'Other') AND is_active = 1
ORDER BY RAND() LIMIT @stationery_needed;

UPDATE listings SET category = 'Stationery'
WHERE listing_id IN (SELECT listing_id FROM temp_stationery_fill);
DROP TEMPORARY TABLE IF EXISTS temp_stationery_fill;

-- If Clothing needs more items, randomly select from Electronics/Other
SET @clothing_needed = GREATEST(0, FLOOR(@target_per_category) - @clothing_count);
CREATE TEMPORARY TABLE IF NOT EXISTS temp_clothing_fill AS
SELECT listing_id FROM listings 
WHERE category IN ('Electronics', 'Other') AND is_active = 1
ORDER BY RAND() LIMIT @clothing_needed;

UPDATE listings SET category = 'Clothing'
WHERE listing_id IN (SELECT listing_id FROM temp_clothing_fill);
DROP TEMPORARY TABLE IF EXISTS temp_clothing_fill;

-- Verify final distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

