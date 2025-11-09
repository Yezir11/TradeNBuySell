-- Create One Listing Per Image
-- This script creates 209 listings, one for each image in the uploads directory

USE tradenbysell;

-- Clear existing data
DELETE FROM listing_images;
DELETE FROM listing_tags;
DELETE FROM listings;

-- Get user IDs
SET @student1 = (SELECT user_id FROM users WHERE email = 'student1@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student2 = (SELECT user_id FROM users WHERE email = 'student2@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student3 = (SELECT user_id FROM users WHERE email = 'student3@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student4 = (SELECT user_id FROM users WHERE email = 'student4@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student5 = (SELECT user_id FROM users WHERE email = 'student5@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student6 = (SELECT user_id FROM users WHERE email = 'student6@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student7 = (SELECT user_id FROM users WHERE email = 'student7@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student8 = (SELECT user_id FROM users WHERE email = 'student8@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student9 = (SELECT user_id FROM users WHERE email = 'student9@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student10 = (SELECT user_id FROM users WHERE email = 'student10@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student11 = (SELECT user_id FROM users WHERE email = 'student11@pilani.bits-pilani.ac.in' LIMIT 1);
SET @student12 = (SELECT user_id FROM users WHERE email = 'student12@pilani.bits-pilani.ac.in' LIMIT 1);

SET @listing_1 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_1, @student1, '~1 550x550h', 'Electronics Item for sale. Good condition. Price negotiable.', 3050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_1, 'http://localhost:8080/images/02~1-550x550h.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_1, 'electronics'), (@listing_1, 'item');

SET @listing_2 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_2, @student2, 'D93e447 1cd8 4b7a B2ab 20cba26395d1 300x300', 'Electronics Item for sale. Good condition. Price negotiable.', 3100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_2, 'http://localhost:8080/images/0d93e447-1cd8-4b7a-b2ab-20cba26395d1-300x300.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_2, 'electronics'), (@listing_2, 'item');

SET @listing_3 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_3, @student3, 'Dell P2312 1212', 'Monitor for sale. Good condition. Price negotiable.', 7150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_3, 'http://localhost:8080/images/1-dell-p2312-1212.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_3, 'monitor'), (@listing_3, 'display'), (@listing_3, 'screen');

SET @listing_4 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_4, @student4, 'Year Warranty Floor Standing Manual Cleaning', 'Air Cooler for sale. Good condition. Price negotiable.', 4200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_4, 'http://localhost:8080/images/1-year-warranty-floor-standing-manual-cleaning-iron-air-cooler--418.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_4, 'cooler'), (@listing_4, 'air-cooler'), (@listing_4, 'appliance');

SET @listing_5 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_5, @student5, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 3250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_5, 'http://localhost:8080/images/1.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_5, 'electronics'), (@listing_5, 'item');

SET @listing_6 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_6, @student6, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 3300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_6, 'http://localhost:8080/images/1000063407.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_6, 'electronics'), (@listing_6, 'item');

SET @listing_7 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_7, @student7, '439442251 Oj7h8q0cseavh3hqdqbr4fsrefxrbizf', 'Electronics Item for sale. Good condition. Price negotiable.', 3350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_7, 'http://localhost:8080/images/1000_F_439442251_oj7H8q0CSeAVh3hqDQbr4FsREfXRbIzF.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_7, 'electronics'), (@listing_7, 'item');

SET @listing_8 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_8, @student8, '564609770 Xhdxthijptcsacfqktrpt1h4qf1pdobn', 'Air Cooler for sale. Good condition. Price negotiable.', 4400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_8, 'http://localhost:8080/images/1000_F_564609770_XHdxTHIJptCSACFqktrPt1H4qF1pdObN.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_8, 'cooler'), (@listing_8, 'air-cooler'), (@listing_8, 'appliance');

SET @listing_9 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_9, @student9, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 3450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_9, 'http://localhost:8080/images/12.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_9, 'electronics'), (@listing_9, 'item');

SET @listing_10 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_10, @student10, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 3500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_10, 'http://localhost:8080/images/143636.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_10, 'electronics'), (@listing_10, 'item');

SET @listing_11 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_11, @student11, '1430810677 Vngvggh 190x190', 'Electronics Item for sale. Good condition. Price negotiable.', 3550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_11, 'http://localhost:8080/images/14384-1430810677_vngvggh-190x190.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_11, 'electronics'), (@listing_11, 'item');

SET @listing_12 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_12, @student12, 'Inch Electric Air Cooler', 'Air Cooler for sale. Good condition. Price negotiable.', 4600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_12, 'http://localhost:8080/images/16-Inch-Electric-Air-Cooler.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_12, 'cooler'), (@listing_12, 'air-cooler'), (@listing_12, 'appliance');

SET @listing_13 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_13, @student1, 'Inch Plastic Air Cooler', 'Air Cooler for sale. Good condition. Price negotiable.', 4650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_13, 'http://localhost:8080/images/16-Inch-Plastic-Air-Cooler.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_13, 'cooler'), (@listing_13, 'air-cooler'), (@listing_13, 'appliance');

SET @listing_14 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_14, @student2, 'A6592 D09f5b96 Af3c 4431 9ba6 7dedb68a23c7', 'Electronics Item for sale. Good condition. Price negotiable.', 3700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_14, 'http://localhost:8080/images/160A6592_d09f5b96-af3c-4431-9ba6-7dedb68a23c7.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_14, 'electronics'), (@listing_14, 'item');

SET @listing_15 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_15, @student3, 'A6672 4e4a13da 6b90 4f4f B012 F3c108a16207', 'Electronics Item for sale. Good condition. Price negotiable.', 3750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_15, 'http://localhost:8080/images/160A6672_4e4a13da-6b90-4f4f-b012-f3c108a16207.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_15, 'electronics'), (@listing_15, 'item');

SET @listing_16 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_16, @student4, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 3800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_16, 'http://localhost:8080/images/1633887.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_16, 'electronics'), (@listing_16, 'item');

SET @listing_17 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_17, @student5, 'Sku 7344', 'Electronics Item for sale. Good condition. Price negotiable.', 3850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_17, 'http://localhost:8080/images/1697371031711_SKU-7344_0.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_17, 'electronics'), (@listing_17, 'item');

SET @listing_18 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_18, @student6, 'Monitor 500x633', 'Monitor for sale. Good condition. Price negotiable.', 7900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_18, 'http://localhost:8080/images/17 Monitor-500x633.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_18, 'monitor'), (@listing_18, 'display'), (@listing_18, 'screen');

SET @listing_19 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_19, @student7, '940866abbdd42cbdf', 'Electronics Item for sale. Good condition. Price negotiable.', 3950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_19, 'http://localhost:8080/images/1722531284_940866abbdd42cbdf.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_19, 'electronics'), (@listing_19, 'item');

SET @listing_20 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_20, @student8, '1894980', 'Electronics Item for sale. Good condition. Price negotiable.', 4000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_20, 'http://localhost:8080/images/1747309544_1894980.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_20, 'electronics'), (@listing_20, 'item');

SET @listing_21 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_21, @student9, 'Xlw5r3c8bb', 'Electronics Item for sale. Good condition. Price negotiable.', 4050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_21, 'http://localhost:8080/images/1760251193228_xlw5r3c8bb.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_21, 'electronics'), (@listing_21, 'item');

SET @listing_22 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_22, @student10, '26', 'Electronics Item for sale. Good condition. Price negotiable.', 4100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_22, 'http://localhost:8080/images/2-26.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_22, 'electronics'), (@listing_22, 'item');

SET @listing_23 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_23, @student11, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 4150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_23, 'http://localhost:8080/images/2.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_23, 'electronics'), (@listing_23, 'item');

SET @listing_24 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_24, @student12, 'Stainless Steel Air Cooler Silver 35', 'Air Cooler for sale. Good condition. Price negotiable.', 5200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_24, 'http://localhost:8080/images/202-stainless-steel-air-cooler-silver-35-ltr-2224699012-nn85bng6.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_24, 'cooler'), (@listing_24, 'air-cooler'), (@listing_24, 'appliance');

SET @listing_25 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_25, @student1, 'Fa9727f33d', 'Electronics Item for sale. Good condition. Price negotiable.', 4250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_25, 'http://localhost:8080/images/26834124862_fa9727f33d_z.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_25, 'electronics'), (@listing_25, 'item');

SET @listing_26 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_26, @student2, 'Envy City Cycle With Inbuilt Carrier', 'Bicycle for sale. Good condition. Price negotiable.', 5800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_26, 'http://localhost:8080/images/26t-envy-city-cycle-with-inbuilt-carrier-5740238.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_26, 'bicycle'), (@listing_26, 'cycle'), (@listing_26, 'bike');

SET @listing_27 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_27, @student3, 'White Downtown Hybrid Cycle 9953852', 'Bicycle for sale. Good condition. Price negotiable.', 5850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_27, 'http://localhost:8080/images/26t-white-downtown-hybrid-cycle-9953852.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_27, 'bicycle'), (@listing_27, 'cycle'), (@listing_27, 'bike');

SET @listing_28 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_28, @student4, 'Legender150swleftlightgrey', 'Electronics Item for sale. Good condition. Price negotiable.', 4400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_28, 'http://localhost:8080/images/2Legender150SWLEFTLightGrey_1.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_28, 'electronics'), (@listing_28, 'item');

SET @listing_29 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_29, @student5, 'Af7bfb3 2508 4b34 94a0 1825e5888b2d', 'Electronics Item for sale. Good condition. Price negotiable.', 4450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_29, 'http://localhost:8080/images/2af7bfb3-2508-4b34-94a0-1825e5888b2d.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_29, 'electronics'), (@listing_29, 'item');

SET @listing_30 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_30, @student6, 'Industrial Air Cooler Air Cooling Machine', 'Air Cooler for sale. Good condition. Price negotiable.', 5500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_30, 'http://localhost:8080/images/30L-Industrial-Air-Cooler-Air-Cooling-Machine-with-Factory-Price.jpg_300x300.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_30, 'cooler'), (@listing_30, 'air-cooler'), (@listing_30, 'appliance');

SET @listing_31 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_31, @student7, '29', 'Electronics Item for sale. Good condition. Price negotiable.', 4550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_31, 'http://localhost:8080/images/322666-29.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_31, 'electronics'), (@listing_31, 'item');

SET @listing_32 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_32, @student8, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 4600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_32, 'http://localhost:8080/images/3269766.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_32, 'electronics'), (@listing_32, 'item');

SET @listing_33 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_33, @student9, 'Aio07 6914 4141', 'Electronics Item for sale. Good condition. Price negotiable.', 4650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_33, 'http://localhost:8080/images/328-AIO07-6914-4141.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_33, 'electronics'), (@listing_33, 'item');

SET @listing_34 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_34, @student10, 'D1d3b3ba0093da974f168dea221cabc9f38', 'Electronics Item for sale. Good condition. Price negotiable.', 4700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_34, 'http://localhost:8080/images/32993d1d3b3ba0093da974f168dea221cabc9f38.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_34, 'electronics'), (@listing_34, 'item');

SET @listing_35 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_35, @student11, 'A021b 1469 2121 008', 'Electronics Item for sale. Good condition. Price negotiable.', 4750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_35, 'http://localhost:8080/images/338-A021B-1469-2121_008.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_35, 'electronics'), (@listing_35, 'item');

SET @listing_36 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_36, @student12, '1008508752 Dessq0t3jekobsvxqztyvjoqpnlvtdrv', 'Electronics Item for sale. Good condition. Price negotiable.', 4800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_36, 'http://localhost:8080/images/360_F_1008508752_dESSq0t3JekobsVXqZTYVJOqPNLVTdRv.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_36, 'electronics'), (@listing_36, 'item');

SET @listing_37 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_37, @student1, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 4850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_37, 'http://localhost:8080/images/533d.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_37, 'electronics'), (@listing_37, 'item');

SET @listing_38 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_38, @student2, 'Edcb217e809c744a1124f7 Dell Monitor Lcd 24 P2417h', 'Monitor for sale. Good condition. Price negotiable.', 8900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_38, 'http://localhost:8080/images/64edcb217e809c744a1124f7-dell-monitor-lcd-24-p2417h-used.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_38, 'monitor'), (@listing_38, 'display'), (@listing_38, 'screen');

SET @listing_39 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_39, @student3, 'B7514d2a775529b7613e0c Pre Owned Soundcore Life Tune', 'Headphones for sale. Good condition. Price negotiable.', 5450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_39, 'http://localhost:8080/images/65b7514d2a775529b7613e0c-pre-owned-soundcore-life-tune-xr.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_39, 'headphones'), (@listing_39, 'audio'), (@listing_39, 'sound');

SET @listing_40 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_40, @student4, 'E2b4c6f1391e04a8781 66f164b9d671e4bda7f2591f 240813 Thred...', 'Shoes for sale. Good condition. Price negotiable.', 4500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_40, 'http://localhost:8080/images/67228e2b4c6f1391e04a8781_66f164b9d671e4bda7f2591f_240813_ThredUp_Shot_09-Sneakers_027.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_40, 'shoes'), (@listing_40, 'sneakers'), (@listing_40, 'footwear');

SET @listing_41 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_41, @student5, '00880.1724964580', 'Electronics Item for sale. Good condition. Price negotiable.', 5050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_41, 'http://localhost:8080/images/67902-5__00880.1724964580.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_41, 'electronics'), (@listing_41, 'item');

SET @listing_42 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_42, @student6, 'Zt8sptewl. Ac Uy1000', 'Air Cooler for sale. Good condition. Price negotiable.', 6100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_42, 'http://localhost:8080/images/71ZT8SPTewL._AC_UY1000_.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_42, 'cooler'), (@listing_42, 'air-cooler'), (@listing_42, 'appliance');

SET @listing_43 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_43, @student7, '461 305', 'Electronics Item for sale. Good condition. Price negotiable.', 5150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_43, 'http://localhost:8080/images/741-461-305.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_43, 'electronics'), (@listing_43, 'item');

SET @listing_44 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_44, @student8, 'A1bcb016cebe4d08a4f71532cf233d9f41b1cbe', 'Electronics Item for sale. Good condition. Price negotiable.', 5200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_44, 'http://localhost:8080/images/7a1bcb016cebe4d08a4f71532cf233d9f41b1cbe.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_44, 'electronics'), (@listing_44, 'item');

SET @listing_45 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_45, @student9, 'Item', 'Electronics Item for sale. Good condition. Price negotiable.', 5250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_45, 'http://localhost:8080/images/879253.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_45, 'electronics'), (@listing_45, 'item');

SET @listing_46 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_46, @student10, 'E915d69903b9b5a407b1989b8553c7b84902374', 'Electronics Item for sale. Good condition. Price negotiable.', 5300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_46, 'http://localhost:8080/images/8e915d69903b9b5a407b1989b8553c7b84902374.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_46, 'electronics'), (@listing_46, 'item');

SET @listing_47 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_47, @student11, 'Air Cooler One Time Used Its', 'Air Cooler for sale. Good condition. Price negotiable.', 6350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_47, 'http://localhost:8080/images/AIR-COOLER-ONE-TIME-USED-its-working-condition-VB201705171774173-ak_WBP1042120557-1759581790.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_47, 'cooler'), (@listing_47, 'air-cooler'), (@listing_47, 'appliance');

SET @listing_48 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_48, @student12, 'Air Cooler', 'Air Cooler for sale. Good condition. Price negotiable.', 6400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_48, 'http://localhost:8080/images/AIR-cooler.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_48, 'cooler'), (@listing_48, 'air-cooler'), (@listing_48, 'appliance');

SET @listing_49 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_49, @student1, 'Adobestock 493399565', 'Electronics Item for sale. Good condition. Price negotiable.', 5450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_49, 'http://localhost:8080/images/AdobeStock_493399565.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_49, 'electronics'), (@listing_49, 'item');

SET @listing_50 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_50, @student2, 'An Old Worn Out Innerspring Mattress', 'Mattress for sale. Good condition. Price negotiable.', 8500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_50, 'http://localhost:8080/images/An_old_worn_out_innerspring_mattress.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_50, 'mattress'), (@listing_50, 'bed'), (@listing_50, 'furniture');

SET @listing_51 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_51, @student3, 'Billionmsblackred1 600x', 'Air Cooler for sale. Good condition. Price negotiable.', 6550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_51, 'http://localhost:8080/images/BillionMSBlackRed1_600x.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_51, 'cooler'), (@listing_51, 'air-cooler'), (@listing_51, 'appliance');

SET @listing_52 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_52, @student4, 'Blackgreyside', 'Air Cooler for sale. Good condition. Price negotiable.', 6600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_52, 'http://localhost:8080/images/BlackGreySide.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_52, 'cooler'), (@listing_52, 'air-cooler'), (@listing_52, 'appliance');

SET @listing_53 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_53, @student5, 'Bounce 27.5 Black Atb Bike By', 'Bicycle for sale. Good condition. Price negotiable.', 7150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_53, 'http://localhost:8080/images/Bounce-27.5-Black-ATB-Bike-By-Ahoy-Bikes.jpg.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_53, 'bicycle'), (@listing_53, 'cycle'), (@listing_53, 'bike');

SET @listing_54 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_54, @student6, 'Buy A370 Mtb Cycle 27.5t Mountain', 'Bicycle for sale. Good condition. Price negotiable.', 7200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_54, 'http://localhost:8080/images/Buy-A370-MTB-cycle-27.5T-Mountain-Bike-with-Shimano-gear-Black-1.jpg.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_54, 'bicycle'), (@listing_54, 'cycle'), (@listing_54, 'bike');

SET @listing_55 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_55, @student7, 'Cbbede468e814c2d4c8a727d6f 1727419866918', 'Mattress for sale. Good condition. Price negotiable.', 8750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_55, 'http://localhost:8080/images/CBBEDE468E814C2D4C8A727D6F_1727419866918.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_55, 'mattress'), (@listing_55, 'bed'), (@listing_55, 'furniture');

SET @listing_56 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_56, @student8, 'Cjfarb26i4kqbdywmmsavd', 'Electronics Item for sale. Good condition. Price negotiable.', 5800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_56, 'http://localhost:8080/images/CJFArb26i4kQBdywMMSAVD.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_56, 'electronics'), (@listing_56, 'item');

SET @listing_57 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_57, @student9, 'Call Me 78933 83656 Office Revolving', 'Chair for sale. Good condition. Price negotiable.', 5850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_57, 'http://localhost:8080/images/Call-me---78933-83656-Office-revolving-Chair-with-steel-base-ak_LWBP228684044-1759837830.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_57, 'chair'), (@listing_57, 'office'), (@listing_57, 'furniture');

SET @listing_58 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_58, @student10, 'Commercial Air Cooler 125 Ltr', 'Air Cooler for sale. Good condition. Price negotiable.', 6900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_58, 'http://localhost:8080/images/Commercial-Air-Cooler-125-ltr-..webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_58, 'cooler'), (@listing_58, 'air-cooler'), (@listing_58, 'appliance');

SET @listing_59 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_59, @student11, 'Dsc00904 1500x', 'Electronics Item for sale. Good condition. Price negotiable.', 5950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_59, 'http://localhost:8080/images/DSC00904_1500x.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_59, 'electronics'), (@listing_59, 'item');

SET @listing_60 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_60, @student12, 'Desktop D6c1b121 6a9b 489d 8af4 6ab1a98b885d', 'Electronics Item for sale. Good condition. Price negotiable.', 6000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_60, 'http://localhost:8080/images/Desktop-1_d6c1b121-6a9b-489d-8af4-6ab1a98b885d.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_60, 'electronics'), (@listing_60, 'item');

SET @listing_61 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_61, @student1, 'Domain27.5t Multispeed 360', 'Electronics Item for sale. Good condition. Price negotiable.', 6050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_61, 'http://localhost:8080/images/Domain27.5T-MultiSpeed-360.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_61, 'electronics'), (@listing_61, 'item');

SET @listing_62 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_62, @student2, 'Hitter26tms Min', 'Electronics Item for sale. Good condition. Price negotiable.', 6100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_62, 'http://localhost:8080/images/HITTER26TMS-1-min.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_62, 'electronics'), (@listing_62, 'item');

SET @listing_63 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_63, @student3, 'Img 20220310 Wa0046', 'Electronics Item for sale. Good condition. Price negotiable.', 6150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_63, 'http://localhost:8080/images/IMG-20220310-WA0046.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_63, 'electronics'), (@listing_63, 'item');

SET @listing_64 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_64, @student4, 'Img 1194 Scaled 1080x1080', 'Electronics Item for sale. Good condition. Price negotiable.', 6200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_64, 'http://localhost:8080/images/IMG_1194-scaled-1080x1080.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_64, 'electronics'), (@listing_64, 'item');

SET @listing_65 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_65, @student5, 'Mountain Small Size', 'Electronics Item for sale. Good condition. Price negotiable.', 6250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_65, 'http://localhost:8080/images/MOUNTAIN-W-small-size.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_65, 'electronics'), (@listing_65, 'item');

SET @listing_66 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_66, @student6, 'Men Cycle Under 10000 480x480', 'Bicycle for sale. Good condition. Price negotiable.', 7800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_66, 'http://localhost:8080/images/Men_Cycle_under_10000_480x480.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_66, 'bicycle'), (@listing_66, 'cycle'), (@listing_66, 'bike');

SET @listing_67 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_67, @student7, 'Og 1761897246363', 'Electronics Item for sale. Good condition. Price negotiable.', 6350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_67, 'http://localhost:8080/images/OG-1761897246363.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_67, 'electronics'), (@listing_67, 'item');

SET @listing_68 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_68, @student8, 'Old Mattress', 'Mattress for sale. Good condition. Price negotiable.', 9400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_68, 'http://localhost:8080/images/Old-Mattress-2.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_68, 'mattress'), (@listing_68, 'bed'), (@listing_68, 'furniture');

SET @listing_69 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_69, @student9, 'Orbiter29ddfsdesertstorm 533x', 'Electronics Item for sale. Good condition. Price negotiable.', 6450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_69, 'http://localhost:8080/images/Orbiter29DDFSDesertStorm_533x.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_69, 'electronics'), (@listing_69, 'item');

SET @listing_70 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_70, @student10, 'Pankaj Raika Won The Roat Cycling', 'Electronics Item for sale. Good condition. Price negotiable.', 6500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_70, 'http://localhost:8080/images/Pankaj-Raika-won-the--Roat-4-0--cycling-championsh_1723405622707_1725524546423.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_70, 'electronics'), (@listing_70, 'item');

SET @listing_71 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_71, @student11, 'Shifman Mattress Set', 'Mattress for sale. Good condition. Price negotiable.', 9550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_71, 'http://localhost:8080/images/Shifman_Mattress_Set.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_71, 'mattress'), (@listing_71, 'bed'), (@listing_71, 'furniture');

SET @listing_72 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_72, @student12, 'Steelcase Personality 1166x1536', 'Chair for sale. Good condition. Price negotiable.', 6600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_72, 'http://localhost:8080/images/Steelcase-personality-4-1166x1536-1.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_72, 'chair'), (@listing_72, 'office'), (@listing_72, 'furniture');

SET @listing_73 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_73, @student1, 'Symphony Touch Air Coolers Vb201705171774173 Ak', 'Air Cooler for sale. Good condition. Price negotiable.', 7650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_73, 'http://localhost:8080/images/Symphony-Touch-Air-coolers-VB201705171774173-ak_WBP1833062978-1759653957.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_73, 'cooler'), (@listing_73, 'air-cooler'), (@listing_73, 'appliance');

SET @listing_74 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_74, @student2, 'T00364 F8623e0e Deea 4d3a Aed2 268a49300c9b', 'Electronics Item for sale. Good condition. Price negotiable.', 6700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_74, 'http://localhost:8080/images/T00364_1_f8623e0e-deea-4d3a-aed2-268a49300c9b.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_74, 'electronics'), (@listing_74, 'item');

SET @listing_75 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_75, @student3, 'T05863', 'Electronics Item for sale. Good condition. Price negotiable.', 6750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_75, 'http://localhost:8080/images/T05863_1.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_75, 'electronics'), (@listing_75, 'item');

SET @listing_76 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_76, @student4, 'The Air Cooler Has Been Purchased', 'Air Cooler for sale. Good condition. Price negotiable.', 7800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_76, 'http://localhost:8080/images/The-Air-cooler-has-been-purchased-under-warranty-not-used-more-than-a-week--brand-new-purchase-original-bill-attached-with-1-year-warranty-pending-if-you-buy-VB201705171774173-ak_LWBP1598478027-1758868991.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_76, 'cooler'), (@listing_76, 'air-cooler'), (@listing_76, 'appliance');

SET @listing_77 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_77, @student5, 'The Air Cooler Has Been Purchased', 'Air Cooler for sale. Good condition. Price negotiable.', 7850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_77, 'http://localhost:8080/images/The-Air-cooler-has-been-purchased-under-warranty-not-used-more-than-a-week--brand-new-purchase-original-bill-attached-with-1-year-warranty-pending-if-you-buy-VB201705171774173-ak_LWBP947384800-1758869021.webp', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_77, 'cooler'), (@listing_77, 'air-cooler'), (@listing_77, 'appliance');

SET @listing_78 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_78, @student6, 'Torqx27redcegrey 533x', 'Electronics Item for sale. Good condition. Price negotiable.', 6900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_78, 'http://localhost:8080/images/TorqX27RedCEGrey_533x.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_78, 'electronics'), (@listing_78, 'item');

SET @listing_79 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_79, @student7, 'Untitled 1aht984tywhoirhgw', 'Electronics Item for sale. Good condition. Price negotiable.', 6950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_79, 'http://localhost:8080/images/Untitled-1aht984tywhoirhgw.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_79, 'electronics'), (@listing_79, 'item');

SET @listing_80 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_80, @student8, 'Whatsapp Image 2025 02 03 At', 'Electronics Item for sale. Good condition. Price negotiable.', 7000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_80, 'http://localhost:8080/images/WhatsApp-Image-2025-02-03-at-1.46.42-PM.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_80, 'electronics'), (@listing_80, 'item');

SET @listing_81 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_81, @student9, 'Whatsappimage2021 12 15at3.33.54pm', 'Electronics Item for sale. Good condition. Price negotiable.', 7050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_81, 'http://localhost:8080/images/WhatsAppImage2021-12-15at3.33.54PM.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_81, 'electronics'), (@listing_81, 'item');

SET @listing_82 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_82, @student10, 'Whatsappimage2021 12 15at3.33.55pm 300x300', 'Electronics Item for sale. Good condition. Price negotiable.', 7100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_82, 'http://localhost:8080/images/WhatsAppImage2021-12-15at3.33.55PM_1_300x300.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_82, 'electronics'), (@listing_82, 'item');

SET @listing_83 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_83, @student11, 'Whatsappimage2024 09 20at12050pm1 1726818946850', 'Electronics Item for sale. Good condition. Price negotiable.', 7150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_83, 'http://localhost:8080/images/WhatsAppImage2024-09-20at12050PM1-1726818946850.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_83, 'electronics'), (@listing_83, 'item');

SET @listing_84 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_84, @student12, 'Zwkvck8ja4bvfi6tddhn75', 'Electronics Item for sale. Good condition. Price negotiable.', 7200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_84, 'http://localhost:8080/images/ZwKVck8JA4bvfi6tddhn75.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_84, 'electronics'), (@listing_84, 'item');

SET @listing_85 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_85, @student1, '87563688 Headphonesjack', 'Mobile Phone for sale. Good condition. Price negotiable.', 12250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_85, 'http://localhost:8080/images/_87563688_headphonesjack.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_85, 'mobile'), (@listing_85, 'phone'), (@listing_85, 'smartphone');

SET @listing_86 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_86, @student2, 'Abandoned Room Mattress Garbage Old Cover', 'Mattress for sale. Good condition. Price negotiable.', 10300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_86, 'http://localhost:8080/images/abandoned-room-mattress-garbage-old-cover-stick-hand-lotion-open-condom-wrappers-tissues-newspaper-broken-glass-used-115737067.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_86, 'mattress'), (@listing_86, 'bed'), (@listing_86, 'furniture');

SET @listing_87 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_87, @student3, 'Acer Used Led Monitor Full Hd', 'Monitor for sale. Good condition. Price negotiable.', 11350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_87, 'http://localhost:8080/images/acer-used---led-monitor---full-hd-1080p---24-inch-with-stand-and-power-cable.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_87, 'monitor'), (@listing_87, 'display'), (@listing_87, 'screen');

SET @listing_88 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_88, @student4, 'Air Cooler Used Waiting Area Hospital', 'Air Cooler for sale. Good condition. Price negotiable.', 8400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_88, 'http://localhost:8080/images/air-cooler-used-waiting-area-hospital-which-covid-vaccination-centre-offers-easy-way-to-cool-large-open-219036925.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_88, 'cooler'), (@listing_88, 'air-cooler'), (@listing_88, 'appliance');

SET @listing_89 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_89, @student5, 'Akg Akg K271 Studio Headphones Used', 'Mobile Phone for sale. Good condition. Price negotiable.', 12450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_89, 'http://localhost:8080/images/akg-akg-k271-studio-headphones-used.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_89, 'mobile'), (@listing_89, 'phone'), (@listing_89, 'smartphone');

SET @listing_90 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_90, @student6, 'Akg Akg K812 Headphones Used', 'Mobile Phone for sale. Good condition. Price negotiable.', 12500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_90, 'http://localhost:8080/images/akg-akg-k812-headphones-used.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_90, 'mobile'), (@listing_90, 'phone'), (@listing_90, 'smartphone');

SET @listing_91 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_91, @student7, 'An Audio Headset Is Worn Out', 'Headphones for sale. Good condition. Price negotiable.', 8050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_91, 'http://localhost:8080/images/an-audio-headset-is-worn-out-after-a-short-time-without-having-been-used-intensively-an-example-of-planned-technological-obsolescence-2AXWMYW.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_91, 'headphones'), (@listing_91, 'audio'), (@listing_91, 'sound');

SET @listing_92 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_92, @student8, 'B61cde2c F136 439f 8a96 2710b36b24f9', 'Electronics Item for sale. Good condition. Price negotiable.', 7600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_92, 'http://localhost:8080/images/b61cde2c-f136-439f-8a96-2710b36b24f9.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_92, 'electronics'), (@listing_92, 'item');

SET @listing_93 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_93, @student9, 'Best Place To Sell Shoes 1024x682', 'Air Cooler for sale. Good condition. Price negotiable.', 8650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_93, 'http://localhost:8080/images/best-place-to-sell-shoes-1024x682.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_93, 'cooler'), (@listing_93, 'air-cooler'), (@listing_93, 'appliance');

SET @listing_94 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_94, @student10, 'Bicycle 7351563 640', 'Bicycle for sale. Good condition. Price negotiable.', 9200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_94, 'http://localhost:8080/images/bicycle-7351563_640.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_94, 'bicycle'), (@listing_94, 'cycle'), (@listing_94, 'bike');

SET @listing_95 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_95, @student11, 'Bicycles 1717146845944 1717146864676', 'Bicycle for sale. Good condition. Price negotiable.', 9250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_95, 'http://localhost:8080/images/bicycles_n_1717146845944_1717146864676.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_95, 'bicycle'), (@listing_95, 'cycle'), (@listing_95, 'bike');

SET @listing_96 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_96, @student12, 'Blog 1024x683 Mattress Become Old 2400x', 'Mattress for sale. Good condition. Price negotiable.', 10800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_96, 'http://localhost:8080/images/blog_1024X683_Mattress_Become_Old_2_2400x.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_96, 'mattress'), (@listing_96, 'bed'), (@listing_96, 'furniture');

SET @listing_97 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_97, @student1, 'Bossh Air Cooler Ring Fitted With', 'Air Cooler for sale. Good condition. Price negotiable.', 8850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_97, 'http://localhost:8080/images/bossh-air-cooler-ring-fitted-with-motor-and-pump-150-ltr-2224181974-6w74g1oy.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_97, 'cooler'), (@listing_97, 'air-cooler'), (@listing_97, 'appliance');

SET @listing_98 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_98, @student2, 'C17cfd0e96353ace1727791166843', 'Air Cooler for sale. Good condition. Price negotiable.', 8900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_98, 'http://localhost:8080/images/c17cfd0e96353ace1727791166843.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_98, 'cooler'), (@listing_98, 'air-cooler'), (@listing_98, 'appliance');

SET @listing_99 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_99, @student3, 'C71f10fc566e700ef60bdab140b2c10d', 'Electronics Item for sale. Good condition. Price negotiable.', 7950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_99, 'http://localhost:8080/images/c71f10fc566e700ef60bdab140b2c10d.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_99, 'electronics'), (@listing_99, 'item');

SET @listing_100 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_100, @student4, 'Cfa21189 3ef6 4580 A703 3cdccea22c31', 'Electronics Item for sale. Good condition. Price negotiable.', 8000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_100, 'http://localhost:8080/images/cfa21189-3ef6-4580-a703-3cdccea22c31.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_100, 'electronics'), (@listing_100, 'item');

SET @listing_101 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_101, @student5, 'Chairs For Sale 979', 'Chair for sale. Good condition. Price negotiable.', 8050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_101, 'http://localhost:8080/images/chairs-for-sale-979.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_101, 'chair'), (@listing_101, 'office'), (@listing_101, 'furniture');

SET @listing_102 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_102, @student6, 'Commercial Air Cooler 1723397040 7560939', 'Air Cooler for sale. Good condition. Price negotiable.', 9100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_102, 'http://localhost:8080/images/commercial-air-cooler-1723397040-7560939.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_102, 'cooler'), (@listing_102, 'air-cooler'), (@listing_102, 'appliance');

SET @listing_103 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_103, @student7, 'Default (1)', 'Electronics Item for sale. Good condition. Price negotiable.', 8150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_103, 'http://localhost:8080/images/default (1).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_103, 'electronics'), (@listing_103, 'item');

SET @listing_104 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_104, @student8, 'Default (10)', 'Electronics Item for sale. Good condition. Price negotiable.', 8200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_104, 'http://localhost:8080/images/default (10).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_104, 'electronics'), (@listing_104, 'item');

SET @listing_105 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_105, @student9, 'Default (11)', 'Electronics Item for sale. Good condition. Price negotiable.', 8250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_105, 'http://localhost:8080/images/default (11).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_105, 'electronics'), (@listing_105, 'item');

SET @listing_106 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_106, @student10, 'Default (12)', 'Electronics Item for sale. Good condition. Price negotiable.', 8300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_106, 'http://localhost:8080/images/default (12).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_106, 'electronics'), (@listing_106, 'item');

SET @listing_107 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_107, @student11, 'Default (13)', 'Electronics Item for sale. Good condition. Price negotiable.', 8350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_107, 'http://localhost:8080/images/default (13).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_107, 'electronics'), (@listing_107, 'item');

SET @listing_108 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_108, @student12, 'Default (14)', 'Electronics Item for sale. Good condition. Price negotiable.', 8400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_108, 'http://localhost:8080/images/default (14).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_108, 'electronics'), (@listing_108, 'item');

SET @listing_109 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_109, @student1, 'Default (15)', 'Electronics Item for sale. Good condition. Price negotiable.', 8450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_109, 'http://localhost:8080/images/default (15).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_109, 'electronics'), (@listing_109, 'item');

SET @listing_110 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_110, @student2, 'Default (16)', 'Electronics Item for sale. Good condition. Price negotiable.', 8500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_110, 'http://localhost:8080/images/default (16).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_110, 'electronics'), (@listing_110, 'item');

SET @listing_111 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_111, @student3, 'Default (17)', 'Electronics Item for sale. Good condition. Price negotiable.', 8550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_111, 'http://localhost:8080/images/default (17).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_111, 'electronics'), (@listing_111, 'item');

SET @listing_112 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_112, @student4, 'Default (18)', 'Electronics Item for sale. Good condition. Price negotiable.', 8600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_112, 'http://localhost:8080/images/default (18).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_112, 'electronics'), (@listing_112, 'item');

SET @listing_113 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_113, @student5, 'Default (19)', 'Electronics Item for sale. Good condition. Price negotiable.', 8650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_113, 'http://localhost:8080/images/default (19).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_113, 'electronics'), (@listing_113, 'item');

SET @listing_114 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_114, @student6, 'Default (2)', 'Electronics Item for sale. Good condition. Price negotiable.', 8700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_114, 'http://localhost:8080/images/default (2).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_114, 'electronics'), (@listing_114, 'item');

SET @listing_115 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_115, @student7, 'Default (20)', 'Electronics Item for sale. Good condition. Price negotiable.', 8750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_115, 'http://localhost:8080/images/default (20).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_115, 'electronics'), (@listing_115, 'item');

SET @listing_116 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_116, @student8, 'Default (21)', 'Electronics Item for sale. Good condition. Price negotiable.', 8800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_116, 'http://localhost:8080/images/default (21).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_116, 'electronics'), (@listing_116, 'item');

SET @listing_117 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_117, @student9, 'Default (22)', 'Electronics Item for sale. Good condition. Price negotiable.', 8850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_117, 'http://localhost:8080/images/default (22).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_117, 'electronics'), (@listing_117, 'item');

SET @listing_118 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_118, @student10, 'Default (23)', 'Electronics Item for sale. Good condition. Price negotiable.', 8900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_118, 'http://localhost:8080/images/default (23).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_118, 'electronics'), (@listing_118, 'item');

SET @listing_119 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_119, @student11, 'Default (25)', 'Electronics Item for sale. Good condition. Price negotiable.', 8950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_119, 'http://localhost:8080/images/default (25).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_119, 'electronics'), (@listing_119, 'item');

SET @listing_120 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_120, @student12, 'Default (26)', 'Electronics Item for sale. Good condition. Price negotiable.', 9000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_120, 'http://localhost:8080/images/default (26).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_120, 'electronics'), (@listing_120, 'item');

SET @listing_121 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_121, @student1, 'Default (27)', 'Electronics Item for sale. Good condition. Price negotiable.', 9050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_121, 'http://localhost:8080/images/default (27).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_121, 'electronics'), (@listing_121, 'item');

SET @listing_122 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_122, @student2, 'Default (28)', 'Electronics Item for sale. Good condition. Price negotiable.', 9100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_122, 'http://localhost:8080/images/default (28).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_122, 'electronics'), (@listing_122, 'item');

SET @listing_123 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_123, @student3, 'Default (29)', 'Electronics Item for sale. Good condition. Price negotiable.', 9150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_123, 'http://localhost:8080/images/default (29).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_123, 'electronics'), (@listing_123, 'item');

SET @listing_124 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_124, @student4, 'Default (30)', 'Electronics Item for sale. Good condition. Price negotiable.', 9200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_124, 'http://localhost:8080/images/default (30).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_124, 'electronics'), (@listing_124, 'item');

SET @listing_125 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_125, @student5, 'Default (31)', 'Electronics Item for sale. Good condition. Price negotiable.', 9250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_125, 'http://localhost:8080/images/default (31).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_125, 'electronics'), (@listing_125, 'item');

SET @listing_126 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_126, @student6, 'Default (32)', 'Electronics Item for sale. Good condition. Price negotiable.', 9300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_126, 'http://localhost:8080/images/default (32).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_126, 'electronics'), (@listing_126, 'item');

SET @listing_127 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_127, @student7, 'Default (33)', 'Electronics Item for sale. Good condition. Price negotiable.', 9350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_127, 'http://localhost:8080/images/default (33).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_127, 'electronics'), (@listing_127, 'item');

SET @listing_128 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_128, @student8, 'Default (34)', 'Electronics Item for sale. Good condition. Price negotiable.', 9400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_128, 'http://localhost:8080/images/default (34).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_128, 'electronics'), (@listing_128, 'item');

SET @listing_129 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_129, @student9, 'Default (36)', 'Electronics Item for sale. Good condition. Price negotiable.', 9450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_129, 'http://localhost:8080/images/default (36).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_129, 'electronics'), (@listing_129, 'item');

SET @listing_130 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_130, @student10, 'Default (37)', 'Electronics Item for sale. Good condition. Price negotiable.', 9500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_130, 'http://localhost:8080/images/default (37).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_130, 'electronics'), (@listing_130, 'item');

SET @listing_131 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_131, @student11, 'Default (38)', 'Electronics Item for sale. Good condition. Price negotiable.', 9550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_131, 'http://localhost:8080/images/default (38).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_131, 'electronics'), (@listing_131, 'item');

SET @listing_132 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_132, @student12, 'Default (39)', 'Electronics Item for sale. Good condition. Price negotiable.', 9600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_132, 'http://localhost:8080/images/default (39).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_132, 'electronics'), (@listing_132, 'item');

SET @listing_133 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_133, @student1, 'Default (4)', 'Electronics Item for sale. Good condition. Price negotiable.', 9650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_133, 'http://localhost:8080/images/default (4).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_133, 'electronics'), (@listing_133, 'item');

SET @listing_134 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_134, @student2, 'Default (40)', 'Electronics Item for sale. Good condition. Price negotiable.', 9700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_134, 'http://localhost:8080/images/default (40).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_134, 'electronics'), (@listing_134, 'item');

SET @listing_135 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_135, @student3, 'Default (41)', 'Electronics Item for sale. Good condition. Price negotiable.', 9750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_135, 'http://localhost:8080/images/default (41).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_135, 'electronics'), (@listing_135, 'item');

SET @listing_136 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_136, @student4, 'Default (42)', 'Electronics Item for sale. Good condition. Price negotiable.', 9800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_136, 'http://localhost:8080/images/default (42).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_136, 'electronics'), (@listing_136, 'item');

SET @listing_137 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_137, @student5, 'Default (43)', 'Electronics Item for sale. Good condition. Price negotiable.', 9850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_137, 'http://localhost:8080/images/default (43).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_137, 'electronics'), (@listing_137, 'item');

SET @listing_138 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_138, @student6, 'Default (44)', 'Electronics Item for sale. Good condition. Price negotiable.', 9900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_138, 'http://localhost:8080/images/default (44).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_138, 'electronics'), (@listing_138, 'item');

SET @listing_139 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_139, @student7, 'Default (45)', 'Electronics Item for sale. Good condition. Price negotiable.', 9950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_139, 'http://localhost:8080/images/default (45).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_139, 'electronics'), (@listing_139, 'item');

SET @listing_140 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_140, @student8, 'Default (46)', 'Electronics Item for sale. Good condition. Price negotiable.', 10000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_140, 'http://localhost:8080/images/default (46).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_140, 'electronics'), (@listing_140, 'item');

SET @listing_141 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_141, @student9, 'Default (48)', 'Electronics Item for sale. Good condition. Price negotiable.', 10050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_141, 'http://localhost:8080/images/default (48).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_141, 'electronics'), (@listing_141, 'item');

SET @listing_142 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_142, @student10, 'Default (49)', 'Electronics Item for sale. Good condition. Price negotiable.', 10100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_142, 'http://localhost:8080/images/default (49).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_142, 'electronics'), (@listing_142, 'item');

SET @listing_143 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_143, @student11, 'Default (5)', 'Electronics Item for sale. Good condition. Price negotiable.', 10150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_143, 'http://localhost:8080/images/default (5).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_143, 'electronics'), (@listing_143, 'item');

SET @listing_144 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_144, @student12, 'Default (51)', 'Electronics Item for sale. Good condition. Price negotiable.', 10200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_144, 'http://localhost:8080/images/default (51).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_144, 'electronics'), (@listing_144, 'item');

SET @listing_145 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_145, @student1, 'Default (52)', 'Electronics Item for sale. Good condition. Price negotiable.', 10250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_145, 'http://localhost:8080/images/default (52).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_145, 'electronics'), (@listing_145, 'item');

SET @listing_146 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_146, @student2, 'Default (53)', 'Electronics Item for sale. Good condition. Price negotiable.', 10300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_146, 'http://localhost:8080/images/default (53).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_146, 'electronics'), (@listing_146, 'item');

SET @listing_147 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_147, @student3, 'Default (54)', 'Electronics Item for sale. Good condition. Price negotiable.', 10350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_147, 'http://localhost:8080/images/default (54).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_147, 'electronics'), (@listing_147, 'item');

SET @listing_148 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_148, @student4, 'Default (55)', 'Electronics Item for sale. Good condition. Price negotiable.', 10400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_148, 'http://localhost:8080/images/default (55).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_148, 'electronics'), (@listing_148, 'item');

SET @listing_149 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_149, @student5, 'Default (56)', 'Electronics Item for sale. Good condition. Price negotiable.', 10450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_149, 'http://localhost:8080/images/default (56).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_149, 'electronics'), (@listing_149, 'item');

SET @listing_150 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_150, @student6, 'Default (57)', 'Electronics Item for sale. Good condition. Price negotiable.', 10500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_150, 'http://localhost:8080/images/default (57).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_150, 'electronics'), (@listing_150, 'item');

SET @listing_151 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_151, @student7, 'Default (6)', 'Electronics Item for sale. Good condition. Price negotiable.', 10550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_151, 'http://localhost:8080/images/default (6).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_151, 'electronics'), (@listing_151, 'item');

SET @listing_152 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_152, @student8, 'Default (8)', 'Electronics Item for sale. Good condition. Price negotiable.', 10600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_152, 'http://localhost:8080/images/default (8).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_152, 'electronics'), (@listing_152, 'item');

SET @listing_153 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_153, @student9, 'Default (9)', 'Electronics Item for sale. Good condition. Price negotiable.', 10650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_153, 'http://localhost:8080/images/default (9).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_153, 'electronics'), (@listing_153, 'item');

SET @listing_154 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_154, @student10, 'Defaultcycleherohaicarouselimage', 'Bicycle for sale. Good condition. Price negotiable.', 12200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_154, 'http://localhost:8080/images/defaultCycleHeroHaiCarouselImage.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_154, 'bicycle'), (@listing_154, 'cycle'), (@listing_154, 'bike');

SET @listing_155 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_155, @student11, 'East Coast Premium City Bike Cycle', 'Bicycle for sale. Good condition. Price negotiable.', 12250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_155, 'http://localhost:8080/images/east-coast-premium-city-bike-cycle-26t-with-inbuilt-carrier-black-product-images-o493831610-p604517247-0-202409201557.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_155, 'bicycle'), (@listing_155, 'cycle'), (@listing_155, 'bike');

SET @listing_156 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_156, @student12, 'Eb1716eb39823aab47a4a553717a8ccb', 'Electronics Item for sale. Good condition. Price negotiable.', 10800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_156, 'http://localhost:8080/images/eb1716eb39823aab47a4a553717a8ccb.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_156, 'electronics'), (@listing_156, 'item');

SET @listing_157 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_157, @student1, 'Electric Air Coolers 500x500', 'Air Cooler for sale. Good condition. Price negotiable.', 11850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_157, 'http://localhost:8080/images/electric-air-coolers-500x500.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_157, 'cooler'), (@listing_157, 'air-cooler'), (@listing_157, 'appliance');

SET @listing_158 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_158, @student2, 'Emx New', 'Electronics Item for sale. Good condition. Price negotiable.', 10900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_158, 'http://localhost:8080/images/emx-new.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_158, 'electronics'), (@listing_158, 'item');

SET @listing_159 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_159, @student3, 'Foldble 26 Cycle', 'Bicycle for sale. Good condition. Price negotiable.', 12450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_159, 'http://localhost:8080/images/foldble-26-t-cycle.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_159, 'bicycle'), (@listing_159, 'cycle'), (@listing_159, 'bike');

SET @listing_160 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_160, @student4, 'Folding Photoroom', 'Electronics Item for sale. Good condition. Price negotiable.', 11000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_160, 'http://localhost:8080/images/folding-Photoroom.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_160, 'electronics'), (@listing_160, 'item');

SET @listing_161 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_161, @student5, 'Fugitive', 'Electronics Item for sale. Good condition. Price negotiable.', 11050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_161, 'http://localhost:8080/images/fugitive.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_161, 'electronics'), (@listing_161, 'item');

SET @listing_162 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_162, @student6, 'Cea6db90 B85e 4ef6 B4a7 9db16d4cbb2e', 'Electronics Item for sale. Good condition. Price negotiable.', 11100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_162, 'http://localhost:8080/images/g_cea6db90-b85e-4ef6-b4a7-9db16d4cbb2e.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_162, 'electronics'), (@listing_162, 'item');

SET @listing_163 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_163, @student7, 'Gear Cycles Under 10000 1724917308714 1724917326501', 'Bicycle for sale. Good condition. Price negotiable.', 12650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_163, 'http://localhost:8080/images/gear_cycles_under_10000_1724917308714_1724917326501.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_163, 'bicycle'), (@listing_163, 'cycle'), (@listing_163, 'bike');

SET @listing_164 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_164, @student8, 'Grado Labs Grado Labs Gs1000x Headphones', 'Mobile Phone for sale. Good condition. Price negotiable.', 16200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_164, 'http://localhost:8080/images/grado-labs-grado-labs-gs1000x-headphones-used.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_164, 'mobile'), (@listing_164, 'phone'), (@listing_164, 'smartphone');

SET @listing_165 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_165, @student9, 'Hercules Cycles', 'Bicycle for sale. Good condition. Price negotiable.', 12750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_165, 'http://localhost:8080/images/hercules-cycles.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_165, 'bicycle'), (@listing_165, 'cycle'), (@listing_165, 'bike');

SET @listing_166 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_166, @student10, 'High Speed Low Power Consumption Energy', 'Air Cooler for sale. Good condition. Price negotiable.', 12300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_166, 'http://localhost:8080/images/high-speed-low-power-consumption-energy-efficient-floor-standing-air-cooler--673.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_166, 'cooler'), (@listing_166, 'air-cooler'), (@listing_166, 'appliance');

SET @listing_167 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_167, @student11, 'Image', 'Electronics Item for sale. Good condition. Price negotiable.', 11350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_167, 'http://localhost:8080/images/image_4.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_167, 'electronics'), (@listing_167, 'item');

SET @listing_168 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_168, @student12, 'Images (1)', 'Electronics Item for sale. Good condition. Price negotiable.', 11400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_168, 'http://localhost:8080/images/images (1).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_168, 'electronics'), (@listing_168, 'item');

SET @listing_169 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_169, @student1, 'Images (1)', 'Electronics Item for sale. Good condition. Price negotiable.', 11450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_169, 'http://localhost:8080/images/images (1).png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_169, 'electronics'), (@listing_169, 'item');

SET @listing_170 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_170, @student2, 'Images (10)', 'Electronics Item for sale. Good condition. Price negotiable.', 11500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_170, 'http://localhost:8080/images/images (10).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_170, 'electronics'), (@listing_170, 'item');

SET @listing_171 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_171, @student3, 'Images (11)', 'Electronics Item for sale. Good condition. Price negotiable.', 11550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_171, 'http://localhost:8080/images/images (11).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_171, 'electronics'), (@listing_171, 'item');

SET @listing_172 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_172, @student4, 'Images (12)', 'Electronics Item for sale. Good condition. Price negotiable.', 11600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_172, 'http://localhost:8080/images/images (12).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_172, 'electronics'), (@listing_172, 'item');

SET @listing_173 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_173, @student5, 'Images (13)', 'Electronics Item for sale. Good condition. Price negotiable.', 11650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_173, 'http://localhost:8080/images/images (13).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_173, 'electronics'), (@listing_173, 'item');

SET @listing_174 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_174, @student6, 'Images (15)', 'Electronics Item for sale. Good condition. Price negotiable.', 11700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_174, 'http://localhost:8080/images/images (15).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_174, 'electronics'), (@listing_174, 'item');

SET @listing_175 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_175, @student7, 'Images (2)', 'Electronics Item for sale. Good condition. Price negotiable.', 11750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_175, 'http://localhost:8080/images/images (2).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_175, 'electronics'), (@listing_175, 'item');

SET @listing_176 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_176, @student8, 'Images (3)', 'Electronics Item for sale. Good condition. Price negotiable.', 11800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_176, 'http://localhost:8080/images/images (3).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_176, 'electronics'), (@listing_176, 'item');

SET @listing_177 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_177, @student9, 'Images (6)', 'Electronics Item for sale. Good condition. Price negotiable.', 11850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_177, 'http://localhost:8080/images/images (6).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_177, 'electronics'), (@listing_177, 'item');

SET @listing_178 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_178, @student10, 'Images (8)', 'Electronics Item for sale. Good condition. Price negotiable.', 11900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_178, 'http://localhost:8080/images/images (8).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_178, 'electronics'), (@listing_178, 'item');

SET @listing_179 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_179, @student11, 'Images (9)', 'Electronics Item for sale. Good condition. Price negotiable.', 11950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_179, 'http://localhost:8080/images/images (9).jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_179, 'electronics'), (@listing_179, 'item');

SET @listing_180 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_180, @student12, 'Lk5qga3ove Oppo F27 494422689 1200wx1200h5742017913466578313', 'Mobile Phone for sale. Good condition. Price negotiable.', 17000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 0 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_180, 'http://localhost:8080/images/lk5qga3ove-oppo-f27-494422689-i-4-1200wx1200h5742017913466578313.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_180, 'mobile'), (@listing_180, 'phone'), (@listing_180, 'smartphone');

SET @listing_181 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_181, @student1, 'Louis Vuitton Rivoli Sneaker Monogram Red', 'Shoes for sale. Good condition. Price negotiable.', 11550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_181, 'http://localhost:8080/images/louis-vuitton-rivoli-sneaker-monogram-red-white-men-11-uk-95-gently-enjoyed-used-sneakers-jawns-on-fire-sneakers-streetwear-5955417_2048x.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_181, 'shoes'), (@listing_181, 'sneakers'), (@listing_181, 'footwear');

SET @listing_182 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_182, @student2, 'Mar01a', 'Electronics Item for sale. Good condition. Price negotiable.', 12100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_182, 'http://localhost:8080/images/mar01a.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_182, 'electronics'), (@listing_182, 'item');

SET @listing_183 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_183, @student3, 'Maxresdefault', 'Electronics Item for sale. Good condition. Price negotiable.', 12150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_183, 'http://localhost:8080/images/maxresdefault.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_183, 'electronics'), (@listing_183, 'item');

SET @listing_184 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_184, @student4, 'Nike Vapor Lite White Blue Siz', 'Shoes for sale. Good condition. Price negotiable.', 11700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Sports', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_184, 'http://localhost:8080/images/nike_vapor_lite_white_blue_siz_1692685707_c43e3a79_progressive.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_184, 'shoes'), (@listing_184, 'sneakers'), (@listing_184, 'footwear');

SET @listing_185 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_185, @student5, 'Office Economic Chairs 500x500', 'Chair for sale. Good condition. Price negotiable.', 12250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_185, 'http://localhost:8080/images/office-economic-chairs-500x500.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_185, 'chair'), (@listing_185, 'office'), (@listing_185, 'furniture');

SET @listing_186 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_186, @student6, 'Old Ragged Mattress Abandoned House Poor', 'Mattress for sale. Good condition. Price negotiable.', 15300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_186, 'http://localhost:8080/images/old-ragged-mattress-abandoned-house-poor-living-conditions-interior-grunge-style-residential-building-shabby-walls-gloomy-150239114.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_186, 'mattress'), (@listing_186, 'bed'), (@listing_186, 'furniture');

SET @listing_187 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_187, @student7, 'One Year Old Mattress Available For', 'Mattress for sale. Good condition. Price negotiable.', 15350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_187, 'http://localhost:8080/images/one-year-old-mattress-available-for-sale-very-sparingly-used-queen-size--In-very-good-condition-VB201705171774173-ak_LWBP1271032044-1759552571.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_187, 'mattress'), (@listing_187, 'bed'), (@listing_187, 'furniture');

SET @listing_188 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_188, @student8, 'One Year Old Mattress Available For', 'Mattress for sale. Good condition. Price negotiable.', 15400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_188, 'http://localhost:8080/images/one-year-old-mattress-available-for-sale-very-sparingly-used-queen-size--In-very-good-condition-VB201705171774173-ak_LWBP2107269355-1759552547.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_188, 'mattress'), (@listing_188, 'bed'), (@listing_188, 'furniture');

SET @listing_189 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_189, @student9, 'P2361844', 'Electronics Item for sale. Good condition. Price negotiable.', 12450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_189, 'http://localhost:8080/images/p2361844.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_189, 'electronics'), (@listing_189, 'item');

SET @listing_190 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_190, @student10, 'P24h 20171128085326 Removebg Preview', 'Electronics Item for sale. Good condition. Price negotiable.', 12500.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_190, 'http://localhost:8080/images/p24h_20171128085326-removebg-preview.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_190, 'electronics'), (@listing_190, 'item');

SET @listing_191 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_191, @student11, 'P2573449', 'Electronics Item for sale. Good condition. Price negotiable.', 12550.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_191, 'http://localhost:8080/images/p2573449.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_191, 'electronics'), (@listing_191, 'item');

SET @listing_192 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_192, @student12, 'Pexels Photo 1208777', 'Electronics Item for sale. Good condition. Price negotiable.', 12600.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_192, 'http://localhost:8080/images/pexels-photo-1208777.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_192, 'electronics'), (@listing_192, 'item');

SET @listing_193 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_193, @student1, 'Popular Dts Gents 500x500', 'Electronics Item for sale. Good condition. Price negotiable.', 12650.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_193, 'http://localhost:8080/images/popular-dts-gents-500x500.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_193, 'electronics'), (@listing_193, 'item');

SET @listing_194 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_194, @student2, 'L1200', 'Electronics Item for sale. Good condition. Price negotiable.', 12700.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_194, 'http://localhost:8080/images/s-l1200.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_194, 'electronics'), (@listing_194, 'item');

SET @listing_195 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_195, @student3, 'Second Hand Plastic Chairs', 'Chair for sale. Good condition. Price negotiable.', 12750.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_195, 'http://localhost:8080/images/second-hand-Plastic-Chairs.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_195, 'chair'), (@listing_195, 'office'), (@listing_195, 'furniture');

SET @listing_196 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_196, @student4, 'Second Hand And Used Chair 500x500', 'Chair for sale. Good condition. Price negotiable.', 12800.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_196, 'http://localhost:8080/images/second-hand-and-used-chair-500x500.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_196, 'chair'), (@listing_196, 'office'), (@listing_196, 'furniture');

SET @listing_197 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_197, @student5, 'Second Hand And Used Chair', 'Chair for sale. Good condition. Price negotiable.', 12850.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_197, 'http://localhost:8080/images/second-hand-and-used-chair.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_197, 'chair'), (@listing_197, 'office'), (@listing_197, 'furniture');

SET @listing_198 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_198, @student6, 'Second Hand Desert Air Cooler Power', 'Air Cooler for sale. Good condition. Price negotiable.', 13900.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_198, 'http://localhost:8080/images/second-hand-desert-air-cooler-power-consumption-220-v-cornflower-blue-2220048296-cmk3nqkk.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_198, 'cooler'), (@listing_198, 'air-cooler'), (@listing_198, 'appliance');

SET @listing_199 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_199, @student7, 'Shymoon 18 Quot Rocket Commercial Air', 'Air Cooler for sale. Good condition. Price negotiable.', 13950.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_199, 'http://localhost:8080/images/shymoon-18-quot-rocket-commercial-air-cooler-1723396868-7560931.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_199, 'cooler'), (@listing_199, 'air-cooler'), (@listing_199, 'appliance');

SET @listing_200 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_200, @student8, 'Side Finishing', 'Electronics Item for sale. Good condition. Price negotiable.', 13000.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_200, 'http://localhost:8080/images/side-finishing.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_200, 'electronics'), (@listing_200, 'item');

SET @listing_201 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_201, @student9, 'Single Size Mattress', 'Mattress for sale. Good condition. Price negotiable.', 16050.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 21 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_201, 'http://localhost:8080/images/single-size-mattress.png', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_201, 'mattress'), (@listing_201, 'bed'), (@listing_201, 'furniture');

SET @listing_202 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_202, @student10, 'Smart Dream Mattress Wakad Pune Furniture', 'Mattress for sale. Good condition. Price negotiable.', 16100.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 22 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_202, 'http://localhost:8080/images/smart-dream-mattress-wakad-pune-furniture-manufacturers-ik00og14lc.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_202, 'mattress'), (@listing_202, 'bed'), (@listing_202, 'furniture');

SET @listing_203 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_203, @student11, 'Symphony Air Cooler 56 500x500', 'Air Cooler for sale. Good condition. Price negotiable.', 14150.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 23 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_203, 'http://localhost:8080/images/symphony-air-cooler-56-l-500x500.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_203, 'cooler'), (@listing_203, 'air-cooler'), (@listing_203, 'appliance');

SET @listing_204 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_204, @student12, 'Used Plastic Chairs In Bangalore', 'Chair for sale. Good condition. Price negotiable.', 13200.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 24 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_204, 'http://localhost:8080/images/used-Plastic-Chairs-in-bangalore.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_204, 'chair'), (@listing_204, 'office'), (@listing_204, 'furniture');

SET @listing_205 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_205, @student1, 'Used Android Mobile Phones 865', 'Mobile Phone for sale. Good condition. Price negotiable.', 18250.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_205, 'http://localhost:8080/images/used-android-mobile-phones-865.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_205, 'mobile'), (@listing_205, 'phone'), (@listing_205, 'smartphone');

SET @listing_206 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_206, @student2, 'What+happens+to+old+mattresses+ +twilight+bedding 1920w', 'Mattress for sale. Good condition. Price negotiable.', 16300.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 26 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_206, 'http://localhost:8080/images/what+happens+to+old+mattresses+-+Twilight+Bedding-1920w.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_206, 'mattress'), (@listing_206, 'bed'), (@listing_206, 'furniture');

SET @listing_207 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_207, @student3, 'What To Do With Old Mattress', 'Mattress for sale. Good condition. Price negotiable.', 16350.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Furniture', DATE_SUB(NOW(), INTERVAL 27 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_207, 'http://localhost:8080/images/what-to-do-with-old-mattress-topper-scaled.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_207, 'mattress'), (@listing_207, 'bed'), (@listing_207, 'furniture');

SET @listing_208 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_208, @student4, 'Y3683d3f1edd66d', 'Electronics Item for sale. Good condition. Price negotiable.', 13400.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 28 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_208, 'http://localhost:8080/images/y3683d3f1edd66d.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_208, 'electronics'), (@listing_208, 'item');

SET @listing_209 = UUID();
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, starting_price, bid_increment, bid_start_time, bid_end_time, is_active, category, created_at, updated_at)
VALUES (@listing_209, @student5, 'Zhyzu75q1697770732 400x400', 'Electronics Item for sale. Good condition. Price negotiable.', 13450.00, TRUE, FALSE, NULL, NULL, NULL, NULL, TRUE, 'Electronics', DATE_SUB(NOW(), INTERVAL 29 DAY), NOW());

INSERT INTO listing_images (listing_id, image_url, display_order, created_at)
VALUES (@listing_209, 'http://localhost:8080/images/zhyZu75Q1697770732-400x400.jpg', 0, NOW());

INSERT INTO listing_tags (listing_id, tag) VALUES (@listing_209, 'electronics'), (@listing_209, 'item');

-- Total listings created: 209
