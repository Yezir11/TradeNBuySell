-- Fix All Category Mappings - Final Comprehensive Fix
-- This script moves all items to their correct categories based on proper item identification

USE tradenbysell;

-- Step 1: Move ALL Monitors to Electronics (from wherever they are)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bmonitor\\b'
    OR LOWER(description) REGEXP '\\bmonitor\\b'
  );

-- Step 2: Move ALL Headphones to Electronics (from wherever they are)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bheadphone\\b'
    OR LOWER(description) REGEXP '\\bheadphone\\b'
  );

-- Step 3: Move ALL Phones to Electronics (but not headphones)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    (LOWER(title) REGEXP '\\bphone\\b' AND LOWER(title) NOT REGEXP '\\bheadphone\\b')
    OR (LOWER(description) REGEXP '\\bphone\\b' AND LOWER(description) NOT REGEXP '\\bheadphone\\b')
  );

-- Step 4: Move ALL Laptops to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\blaptop\\b'
    OR LOWER(description) REGEXP '\\blaptop\\b'
  );

-- Step 5: Move ALL Tablets to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\btablet\\b'
    OR LOWER(description) REGEXP '\\btablet\\b'
  );

-- Step 6: Move ALL Cameras to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bcamera\\b'
    OR LOWER(description) REGEXP '\\bcamera\\b'
  );

-- Step 7: Move ALL Bicycles to Sports (from wherever they are)
UPDATE listings 
SET category = 'Sports'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bbicycle\\b'
    OR LOWER(title) REGEXP '\\bbike\\b'
    OR LOWER(description) REGEXP '\\bbicycle\\b'
    OR LOWER(description) REGEXP '\\bbike\\b'
  );

-- Step 8: Move ALL Chairs to Furniture (from wherever they are)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bchair\\b'
    OR LOWER(description) REGEXP '\\bchair\\b'
  );

-- Step 9: Move ALL Tables to Furniture (but not tablets)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    (LOWER(title) REGEXP '\\btable\\b' AND LOWER(title) NOT REGEXP '\\btablet\\b')
    OR (LOWER(description) REGEXP '\\btable\\b' AND LOWER(description) NOT REGEXP '\\btablet\\b')
  );

-- Step 10: Move ALL Desks to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bdesk\\b'
    OR LOWER(description) REGEXP '\\bdesk\\b'
  );

-- Step 11: Move ALL Mattresses to Furniture (from wherever they are)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bmattress\\b'
    OR LOWER(description) REGEXP '\\bmattress\\b'
  );

-- Step 12: Move ALL Beds to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bbed\\b'
    OR LOWER(description) REGEXP '\\bbed\\b'
  );

-- Step 13: Move ALL Air Coolers to Appliances (from wherever they are)
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bcooler\\b'
    OR LOWER(description) REGEXP '\\bcooler\\b'
    OR LOWER(title) LIKE '%air cooler%'
    OR LOWER(description) LIKE '%air cooler%'
  );

-- Step 14: Move ALL Fans to Appliances
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bfan\\b'
    OR LOWER(description) REGEXP '\\bfan\\b'
  );

-- Step 15: Move ALL Heaters to Appliances
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bheater\\b'
    OR LOWER(description) REGEXP '\\bheater\\b'
  );

-- Step 16: Ensure Shoes stay in Clothing (they should already be there, but verify)
UPDATE listings 
SET category = 'Clothing'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bshoe\\b'
    OR LOWER(title) REGEXP '\\bsneaker\\b'
    OR LOWER(description) REGEXP '\\bshoe\\b'
    OR LOWER(description) REGEXP '\\bsneaker\\b'
  );

-- Step 17: Move actual Books to Books category (not notebooks)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND (
    (LOWER(title) REGEXP '\\bbook\\b' AND LOWER(title) NOT REGEXP '\\bnotebook\\b')
    OR (LOWER(description) REGEXP '\\bbook\\b' AND LOWER(description) NOT REGEXP '\\bnotebook\\b')
    OR LOWER(title) REGEXP '\\bnovel\\b'
    OR LOWER(description) REGEXP '\\bnovel\\b'
    OR LOWER(title) REGEXP '\\btextbook\\b'
    OR LOWER(description) REGEXP '\\btextbook\\b'
  );

-- Step 18: Move Stationery items (pens, pencils, notebooks) to Stationery
UPDATE listings 
SET category = 'Stationery'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bpen\\b'
    OR LOWER(description) REGEXP '\\bpen\\b'
    OR LOWER(title) REGEXP '\\bpencil\\b'
    OR LOWER(description) REGEXP '\\bpencil\\b'
    OR LOWER(title) REGEXP '\\bnotebook\\b'
    OR LOWER(description) REGEXP '\\bnotebook\\b'
    OR LOWER(title) REGEXP '\\bstationery\\b'
    OR LOWER(description) REGEXP '\\bstationery\\b'
    OR LOWER(title) REGEXP '\\beraser\\b'
    OR LOWER(description) REGEXP '\\beraser\\b'
  )
  AND category NOT IN ('Books'); -- Don't override books

-- Final verification: Show category distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

-- Show breakdown by item type for verification
SELECT 
  category,
  CASE 
    WHEN title LIKE '%monitor%' THEN 'Monitor'
    WHEN title LIKE '%headphone%' THEN 'Headphone'
    WHEN (title LIKE '%phone%' AND title NOT LIKE '%headphone%') THEN 'Phone'
    WHEN title LIKE '%laptop%' THEN 'Laptop'
    WHEN title LIKE '%tablet%' THEN 'Tablet'
    WHEN title LIKE '%camera%' THEN 'Camera'
    WHEN title LIKE '%bicycle%' OR title LIKE '%bike%' THEN 'Bicycle'
    WHEN title LIKE '%shoe%' OR title LIKE '%sneaker%' THEN 'Shoes'
    WHEN title LIKE '%chair%' THEN 'Chair'
    WHEN title LIKE '%table%' AND title NOT LIKE '%tablet%' THEN 'Table'
    WHEN title LIKE '%desk%' THEN 'Desk'
    WHEN title LIKE '%mattress%' THEN 'Mattress'
    WHEN title LIKE '%bed%' THEN 'Bed'
    WHEN title LIKE '%cooler%' THEN 'Air Cooler'
    WHEN title LIKE '%book%' AND title NOT LIKE '%notebook%' THEN 'Book'
    WHEN title LIKE '%pen%' OR title LIKE '%pencil%' THEN 'Pen/Pencil'
    WHEN title LIKE '%notebook%' THEN 'Notebook'
    ELSE 'Other'
  END as item_type,
  COUNT(*) as count
FROM listings 
WHERE is_active = 1
GROUP BY category, item_type
ORDER BY category, count DESC;

