-- Add Appliances Category and Categorize Air Coolers Properly
-- Air coolers are appliances, not electronics

USE tradenbysell;

-- Step 1: Create Appliances category by moving air coolers from Electronics
UPDATE listings 
SET category = 'Appliances'
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bcooler\\b'
    OR LOWER(description) REGEXP '\\bcooler\\b'
    OR LOWER(title) LIKE '%air cooler%'
    OR LOWER(description) LIKE '%air cooler%'
  );

-- Step 2: Move any other appliance-like items to Appliances
-- (fans, heaters, etc. if any exist)
UPDATE listings 
SET category = 'Appliances'
WHERE category = 'Electronics' 
  AND is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bfan\\b'
    OR LOWER(title) REGEXP '\\bheater\\b'
    OR LOWER(description) REGEXP '\\bfan\\b'
    OR LOWER(description) REGEXP '\\bheater\\b'
  );

-- Final distribution check
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

