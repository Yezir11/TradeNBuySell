-- Fix Category Distribution - Simple and Reliable Version
-- This script redistributes listings across the 7 frontend categories:
-- Electronics, Books, Furniture, Clothing, Sports, Stationery, Other

USE tradenbysell;

-- Step 1: Reset all to "Other" first to start fresh
UPDATE listings SET category = 'Other' WHERE is_active = 1;

-- Step 2: Identify Books (using word boundaries with spaces/start/end)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bbook\\b'
    OR LOWER(description) REGEXP '\\bbook\\b'
    OR LOWER(title) REGEXP '\\bnovel\\b'
    OR LOWER(description) REGEXP '\\bnovel\\b'
    OR LOWER(title) REGEXP '\\btextbook\\b'
    OR LOWER(description) REGEXP '\\btextbook\\b'
  );

-- Step 3: Identify Stationery (pens, pencils, notebooks - word boundaries)
UPDATE listings 
SET category = 'Stationery'
WHERE is_active = 1 
  AND category = 'Other'
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
  );

-- Step 4: Identify Clothing (shoes, sneakers - word boundaries)
UPDATE listings 
SET category = 'Clothing'
WHERE is_active = 1 
  AND category = 'Other'
  AND (
    LOWER(title) REGEXP '\\bshoe\\b'
    OR LOWER(title) REGEXP '\\bsneaker\\b'
    OR LOWER(description) REGEXP '\\bshoe\\b'
    OR LOWER(description) REGEXP '\\bsneaker\\b'
  );

-- Step 5: Identify Sports (bicycles, bikes - word boundaries)
UPDATE listings 
SET category = 'Sports'
WHERE is_active = 1 
  AND category = 'Other'
  AND (
    LOWER(title) REGEXP '\\bbicycle\\b'
    OR LOWER(title) REGEXP '\\bbike\\b'
    OR LOWER(description) REGEXP '\\bbicycle\\b'
    OR LOWER(description) REGEXP '\\bbike\\b'
  );

-- Step 6: Identify Furniture (chairs, tables, mattresses, beds - word boundaries)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category = 'Other'
  AND (
    LOWER(title) REGEXP '\\bchair\\b'
    OR LOWER(title) REGEXP '\\btable\\b'
    OR LOWER(title) REGEXP '\\bdesk\\b'
    OR LOWER(title) REGEXP '\\bmattress\\b'
    OR LOWER(title) REGEXP '\\bbed\\b'
    OR LOWER(description) REGEXP '\\bchair\\b'
    OR LOWER(description) REGEXP '\\btable\\b'
    OR LOWER(description) REGEXP '\\bdesk\\b'
    OR LOWER(description) REGEXP '\\bmattress\\b'
    OR LOWER(description) REGEXP '\\bbed\\b'
  );

-- Step 7: Identify Electronics (monitors, headphones, coolers, phones - word boundaries)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND category = 'Other'
  AND (
    LOWER(title) REGEXP '\\bmonitor\\b'
    OR LOWER(title) REGEXP '\\bheadphone\\b'
    OR LOWER(title) REGEXP '\\bcooler\\b'
    OR LOWER(title) REGEXP '\\blaptop\\b'
    OR LOWER(title) REGEXP '\\bphone\\b'
    OR LOWER(title) REGEXP '\\btablet\\b'
    OR LOWER(title) REGEXP '\\bcamera\\b'
    OR LOWER(description) REGEXP '\\bmonitor\\b'
    OR LOWER(description) REGEXP '\\bheadphone\\b'
    OR LOWER(description) REGEXP '\\bcooler\\b'
  );

-- Verify distribution after categorization
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

