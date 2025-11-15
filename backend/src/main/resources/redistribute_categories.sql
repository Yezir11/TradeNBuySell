-- Redistribute Categories Evenly
-- Target: ~61 listings per category (427 total / 7 = 61)

USE tradenbysell;

-- Step 1: Create Books category (~61 items from Other)
CREATE TEMPORARY TABLE temp_books AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 61;

UPDATE listings 
SET category = 'Books'
WHERE listing_id IN (SELECT listing_id FROM temp_books);

DROP TEMPORARY TABLE temp_books;

-- Step 2: Create Stationery category (~61 items from Other)
CREATE TEMPORARY TABLE temp_stationery AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 61;

UPDATE listings 
SET category = 'Stationery'
WHERE listing_id IN (SELECT listing_id FROM temp_stationery);

DROP TEMPORARY TABLE temp_stationery;

-- Step 3: Balance Electronics (currently 80, target 61, move 19 to Other)
CREATE TEMPORARY TABLE temp_electronics_reduce AS
SELECT listing_id FROM listings 
WHERE category = 'Electronics' AND is_active = 1
ORDER BY RAND() LIMIT 19;

UPDATE listings 
SET category = 'Other'
WHERE listing_id IN (SELECT listing_id FROM temp_electronics_reduce);

DROP TEMPORARY TABLE temp_electronics_reduce;

-- Step 4: Balance Furniture (currently 140, target 61, move 79 to Other)
CREATE TEMPORARY TABLE temp_furniture_reduce AS
SELECT listing_id FROM listings 
WHERE category = 'Furniture' AND is_active = 1
ORDER BY RAND() LIMIT 79;

UPDATE listings 
SET category = 'Other'
WHERE listing_id IN (SELECT listing_id FROM temp_furniture_reduce);

DROP TEMPORARY TABLE temp_furniture_reduce;

-- Step 5: Balance Sports (currently 127, target 61, move 66 to Other)
CREATE TEMPORARY TABLE temp_sports_reduce AS
SELECT listing_id FROM listings 
WHERE category = 'Sports' AND is_active = 1
ORDER BY RAND() LIMIT 66;

UPDATE listings 
SET category = 'Other'
WHERE listing_id IN (SELECT listing_id FROM temp_sports_reduce);

DROP TEMPORARY TABLE temp_sports_reduce;

-- Step 6: Balance Clothing (currently 28, needs 33 more from Other)
CREATE TEMPORARY TABLE temp_clothing_add AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 33;

UPDATE listings 
SET category = 'Clothing'
WHERE listing_id IN (SELECT listing_id FROM temp_clothing_add);

DROP TEMPORARY TABLE temp_clothing_add;

-- Step 7: Balance Electronics (should have 61, needs more from Other)
CREATE TEMPORARY TABLE temp_electronics_add AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 19;

UPDATE listings 
SET category = 'Electronics'
WHERE listing_id IN (SELECT listing_id FROM temp_electronics_add);

DROP TEMPORARY TABLE temp_electronics_add;

-- Step 8: Balance Furniture (should have 61, needs more from Other)
CREATE TEMPORARY TABLE temp_furniture_add AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 19;

UPDATE listings 
SET category = 'Furniture'
WHERE listing_id IN (SELECT listing_id FROM temp_furniture_add);

DROP TEMPORARY TABLE temp_furniture_add;

-- Step 9: Balance Sports (should have 61, needs more from Other)
CREATE TEMPORARY TABLE temp_sports_add AS
SELECT listing_id FROM listings 
WHERE category = 'Other' AND is_active = 1
ORDER BY RAND() LIMIT 19;

UPDATE listings 
SET category = 'Sports'
WHERE listing_id IN (SELECT listing_id FROM temp_sports_add);

DROP TEMPORARY TABLE temp_sports_add;

-- Final verification
SELECT category, COUNT(*) as count 
FROM listings 
WHERE is_active = 1 
GROUP BY category 
ORDER BY count DESC;

