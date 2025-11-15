-- Fix Categories with Priority Ordering
-- Electronics items should be identified first (highest priority), then Sports, Furniture, Appliances, etc.

USE tradenbysell;

-- PRIORITY 1: Electronics (highest priority - identify these first)
-- Move ALL Monitors to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bmonitor\\b'
    OR LOWER(description) REGEXP '\\bmonitor\\b'
  );

-- Move ALL Headphones to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND (
    LOWER(title) REGEXP '\\bheadphone\\b'
    OR LOWER(description) REGEXP '\\bheadphone\\b'
  );

-- Move ALL Phones to Electronics (but not headphones)
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND category != 'Electronics'  -- Only if not already Electronics
  AND (
    (LOWER(title) REGEXP '\\bphone\\b' AND LOWER(title) NOT REGEXP '\\bheadphone\\b')
    OR (LOWER(description) REGEXP '\\bphone\\b' AND LOWER(description) NOT REGEXP '\\bheadphone\\b')
  );

-- Move ALL Laptops to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND category != 'Electronics'
  AND (
    LOWER(title) REGEXP '\\blaptop\\b'
    OR LOWER(description) REGEXP '\\blaptop\\b'
  );

-- Move ALL Tablets to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND category != 'Electronics'
  AND (
    LOWER(title) REGEXP '\\btablet\\b'
    OR LOWER(description) REGEXP '\\btablet\\b'
  );

-- Move ALL Cameras to Electronics
UPDATE listings 
SET category = 'Electronics'
WHERE is_active = 1 
  AND category != 'Electronics'
  AND (
    LOWER(title) REGEXP '\\bcamera\\b'
    OR LOWER(description) REGEXP '\\bcamera\\b'
  );

-- PRIORITY 2: Sports
-- Move ALL Bicycles to Sports
UPDATE listings 
SET category = 'Sports'
WHERE is_active = 1 
  AND category != 'Electronics'  -- Don't override Electronics
  AND (
    LOWER(title) REGEXP '\\bbicycle\\b'
    OR LOWER(title) REGEXP '\\bbike\\b'
    OR LOWER(description) REGEXP '\\bbicycle\\b'
    OR LOWER(description) REGEXP '\\bbike\\b'
  );

-- PRIORITY 3: Appliances (before Furniture to avoid conflicts)
-- Move ALL Air Coolers to Appliances
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports')  -- Don't override higher priority
  AND (
    LOWER(title) REGEXP '\\bcooler\\b'
    OR LOWER(description) REGEXP '\\bcooler\\b'
    OR LOWER(title) LIKE '%air cooler%'
    OR LOWER(description) LIKE '%air cooler%'
  );

-- Move ALL Fans to Appliances
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports')
  AND (
    LOWER(title) REGEXP '\\bfan\\b'
    OR LOWER(description) REGEXP '\\bfan\\b'
  );

-- Move ALL Heaters to Appliances
UPDATE listings 
SET category = 'Appliances'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports')
  AND (
    LOWER(title) REGEXP '\\bheater\\b'
    OR LOWER(description) REGEXP '\\bheater\\b'
  );

-- PRIORITY 4: Furniture
-- Move ALL Chairs to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances')
  AND (
    LOWER(title) REGEXP '\\bchair\\b'
    OR LOWER(description) REGEXP '\\bchair\\b'
  );

-- Move ALL Tables to Furniture (but not tablets)
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances')
  AND (
    (LOWER(title) REGEXP '\\btable\\b' AND LOWER(title) NOT REGEXP '\\btablet\\b')
    OR (LOWER(description) REGEXP '\\btable\\b' AND LOWER(description) NOT REGEXP '\\btablet\\b')
  );

-- Move ALL Desks to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances')
  AND (
    LOWER(title) REGEXP '\\bdesk\\b'
    OR LOWER(description) REGEXP '\\bdesk\\b'
  );

-- Move ALL Mattresses to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances')
  AND (
    LOWER(title) REGEXP '\\bmattress\\b'
    OR LOWER(description) REGEXP '\\bmattress\\b'
  );

-- Move ALL Beds to Furniture
UPDATE listings 
SET category = 'Furniture'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances')
  AND (
    LOWER(title) REGEXP '\\bbed\\b'
    OR LOWER(description) REGEXP '\\bbed\\b'
  );

-- PRIORITY 5: Clothing
-- Ensure Shoes stay in Clothing
UPDATE listings 
SET category = 'Clothing'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances', 'Furniture')
  AND (
    LOWER(title) REGEXP '\\bshoe\\b'
    OR LOWER(title) REGEXP '\\bsneaker\\b'
    OR LOWER(description) REGEXP '\\bshoe\\b'
    OR LOWER(description) REGEXP '\\bsneaker\\b'
  );

-- PRIORITY 6: Books
-- Move actual Books to Books category (not notebooks)
UPDATE listings 
SET category = 'Books'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances', 'Furniture', 'Clothing')
  AND (
    (LOWER(title) REGEXP '\\bbook\\b' AND LOWER(title) NOT REGEXP '\\bnotebook\\b')
    OR (LOWER(description) REGEXP '\\bbook\\b' AND LOWER(description) NOT REGEXP '\\bnotebook\\b')
    OR LOWER(title) REGEXP '\\bnovel\\b'
    OR LOWER(description) REGEXP '\\bnovel\\b'
    OR LOWER(title) REGEXP '\\btextbook\\b'
    OR LOWER(description) REGEXP '\\btextbook\\b'
  );

-- PRIORITY 7: Stationery
-- Move Stationery items (pens, pencils, notebooks) to Stationery
UPDATE listings 
SET category = 'Stationery'
WHERE is_active = 1 
  AND category NOT IN ('Electronics', 'Sports', 'Appliances', 'Furniture', 'Clothing', 'Books')
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

-- Final verification: Show category distribution
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

