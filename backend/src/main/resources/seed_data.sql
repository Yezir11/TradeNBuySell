-- TradeNBuySell Demo Seed Data
-- This script populates the database with comprehensive demo data
-- Password for all users: password123
-- BCrypt hash: $2a$10$MB5roPLO3RjnGNifzSBDCO9v.66TawwbFg2s9cLHT6qDJ.LwROZ.G

USE tradenbysell;

-- Clear existing data (optional - comment out if you want to keep existing data)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE moderation_logs;
TRUNCATE TABLE wishlists;
TRUNCATE TABLE feedbacks;
TRUNCATE TABLE reports;
TRUNCATE TABLE ratings;
TRUNCATE TABLE chat_messages;
TRUNCATE TABLE bids;
TRUNCATE TABLE trade_offerings;
TRUNCATE TABLE trades;
TRUNCATE TABLE wallet_transactions;
TRUNCATE TABLE listing_tags;
TRUNCATE TABLE listing_images;
TRUNCATE TABLE listings;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- Password hash for "password123"
SET @password_hash = '$2a$10$MB5roPLO3RjnGNifzSBDCO9v.66TawwbFg2s9cLHT6qDJ.LwROZ.G';

-- ============================================================================
-- USERS
-- ============================================================================
-- Admin User
INSERT INTO users (user_id, email, password_hash, role, full_name, wallet_balance, trust_score, registered_at, is_suspended) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@pilani.bits-pilani.ac.in', @password_hash, 'ADMIN', 'Admin User', 5000.00, 5.0, NOW(), 0);

-- Student Users with varying trust scores (will be updated based on ratings)
INSERT INTO users (user_id, email, password_hash, role, full_name, wallet_balance, trust_score, registered_at, is_suspended) VALUES
-- High trust score users (for trading) - trust scores will be updated from ratings
('11111111-1111-1111-1111-111111111111', 'student1@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Rahul Sharma', 2500.00, 0.0, DATE_SUB(NOW(), INTERVAL 30 DAY), 0),
('22222222-2222-2222-2222-222222222222', 'student2@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Priya Patel', 3200.00, 0.0, DATE_SUB(NOW(), INTERVAL 25 DAY), 0),
('33333333-3333-3333-3333-333333333333', 'student3@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Arjun Kumar', 1800.00, 0.0, DATE_SUB(NOW(), INTERVAL 20 DAY), 0),
('44444444-4444-4444-4444-444444444444', 'student4@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Ananya Singh', 1500.00, 0.0, DATE_SUB(NOW(), INTERVAL 15 DAY), 0),
('55555555-5555-5555-5555-555555555555', 'student5@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Vikram Mehta', 2100.00, 0.0, DATE_SUB(NOW(), INTERVAL 10 DAY), 0),
-- Medium trust score users
('66666666-6666-6666-6666-666666666666', 'student6@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Sneha Reddy', 1400.00, 0.0, DATE_SUB(NOW(), INTERVAL 8 DAY), 0),
('77777777-7777-7777-7777-777777777777', 'student7@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Aditya Joshi', 1900.00, 0.0, DATE_SUB(NOW(), INTERVAL 5 DAY), 0),
-- New users (low trust score, cannot trade)
('88888888-8888-8888-8888-888888888888', 'student8@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Kavya Nair', 1000.00, 0.0, DATE_SUB(NOW(), INTERVAL 3 DAY), 0),
('99999999-9999-9999-9999-999999999999', 'student9@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Rajesh Verma', 1000.00, 0.0, DATE_SUB(NOW(), INTERVAL 1 DAY), 0);

-- ============================================================================
-- LISTINGS
-- ============================================================================
-- Regular Purchase Listings (is_tradeable = 0, is_biddable = 0)
INSERT INTO listings (listing_id, user_id, title, description, price, is_tradeable, is_biddable, is_active, category, created_at) VALUES
-- Electronics
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'MacBook Pro 13" 2020', 'Excellent condition MacBook Pro. Used for 2 years, all accessories included. Battery health 85%.', 45000.00, 0, 0, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'Sony WH-1000XM4 Headphones', 'Premium noise-cancelling headphones. Like new condition, original box and accessories included.', 12000.00, 0, 0, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'iPad Air 4th Gen', '64GB iPad Air in perfect condition. Used for note-taking. Comes with Apple Pencil.', 35000.00, 0, 0, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY)),
-- Furniture
('dddddddd-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444', 'Office Chair - Ergonomic', 'Comfortable office chair with lumbar support. Good condition, minor wear on armrests.', 2500.00, 0, 0, 1, 'Furniture', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '55555555-5555-5555-5555-555555555555', 'Study Desk - Wooden', 'Solid wood study desk with drawers. Spacious and sturdy. Some scratches but fully functional.', 1800.00, 0, 0, 1, 'Furniture', DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- Books
('ffffffff-ffff-ffff-ffff-ffffffffffff', '66666666-6666-6666-6666-666666666666', 'Engineering Textbooks Bundle', 'Complete set of 3rd year CS textbooks. All in good condition with minimal highlighting.', 1500.00, 0, 0, 1, 'Books', DATE_SUB(NOW(), INTERVAL 7 DAY)),
-- Tradeable Listings (is_tradeable = 1, is_biddable = 0)
('gggggggg-gggg-gggg-gggg-gggggggggggg', '11111111-1111-1111-1111-111111111111', 'Gaming Mouse - Logitech G502', 'High-end gaming mouse with RGB lighting. Excellent condition. Open to trades for gaming keyboard.', 2500.00, 1, 0, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 8 DAY)),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', '22222222-2222-2222-2222-222222222222', 'Mechanical Keyboard - RGB', 'RGB mechanical keyboard with Cherry MX switches. Looking to trade for a gaming headset.', 3000.00, 1, 0, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '33333333-3333-3333-3333-333333333333', 'Guitar - Acoustic', 'Yamaha acoustic guitar. Good for beginners. Open to trade for electronic keyboard or cash.', 5000.00, 1, 0, 1, 'Musical Instruments', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', '44444444-4444-4444-4444-444444444444', 'Bicycle - Mountain Bike', 'Mountain bike in good condition. Tires recently replaced. Willing to trade for a road bike or sell.', 8000.00, 1, 0, 1, 'Sports', DATE_SUB(NOW(), INTERVAL 11 DAY)),
-- Biddable Listings (is_tradeable = 0, is_biddable = 1)
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', '55555555-5555-5555-5555-555555555555', 'PlayStation 5 Console', 'PS5 console in excellent condition. Includes controller and games. Auction ends in 3 days.', NULL, 0, 1, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('llllllll-llll-llll-llll-llllllllllll', '66666666-6666-6666-6666-666666666666', 'DJI Mini 2 Drone', 'Compact drone with 4K camera. Barely used, like new. Auction ends in 5 days.', NULL, 0, 1, 1, 'Electronics', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm', '77777777-7777-7777-7777-777777777777', 'Designer Watch - Fossil', 'Stylish Fossil watch. Perfect condition. Auction ends in 7 days.', NULL, 0, 1, 1, 'Accessories', DATE_SUB(NOW(), INTERVAL 4 DAY)),
-- Inactive Listings (for demo)
('nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn', '11111111-1111-1111-1111-111111111111', 'Sold Item - Laptop', 'This item has been sold. For demo purposes only.', 30000.00, 0, 0, 0, 'Electronics', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('oooooooo-oooo-oooo-oooo-oooooooooooo', '22222222-2222-2222-2222-222222222222', 'Flagged Item - Under Review', 'This listing was flagged by ML moderation. Awaiting admin review.', 5000.00, 0, 0, 0, 'Electronics', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Update bid details for biddable listings
UPDATE listings SET 
    starting_price = 35000.00,
    bid_increment = 500.00,
    bid_start_time = DATE_SUB(NOW(), INTERVAL 2 DAY),
    bid_end_time = DATE_ADD(NOW(), INTERVAL 3 DAY)
WHERE listing_id = 'kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk';

UPDATE listings SET 
    starting_price = 25000.00,
    bid_increment = 1000.00,
    bid_start_time = DATE_SUB(NOW(), INTERVAL 3 DAY),
    bid_end_time = DATE_ADD(NOW(), INTERVAL 5 DAY)
WHERE listing_id = 'llllllll-llll-llll-llll-llllllllllll';

UPDATE listings SET 
    starting_price = 8000.00,
    bid_increment = 200.00,
    bid_start_time = DATE_SUB(NOW(), INTERVAL 4 DAY),
    bid_end_time = DATE_ADD(NOW(), INTERVAL 7 DAY)
WHERE listing_id = 'mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm';

-- ============================================================================
-- LISTING IMAGES
-- ============================================================================
-- Note: Image URLs should point to actual uploaded images
-- For demo, using placeholder URLs - replace with actual image paths
INSERT INTO listing_images (listing_id, image_url, display_order, created_at) VALUES
-- MacBook Pro
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '/images/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa-0.jpg', 0, NOW()),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '/images/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa-1.jpg', 1, NOW()),
-- Headphones
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '/images/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb-0.jpg', 0, NOW()),
-- iPad
('cccccccc-cccc-cccc-cccc-cccccccccccc', '/images/cccccccc-cccc-cccc-cccc-cccccccccccc-0.jpg', 0, NOW()),
-- Office Chair
('dddddddd-dddd-dddd-dddd-dddddddddddd', '/images/dddddddd-dddd-dddd-dddd-dddddddddddd-0.jpg', 0, NOW()),
-- Study Desk
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '/images/eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee-0.jpg', 0, NOW()),
-- Books
('ffffffff-ffff-ffff-ffff-ffffffffffff', '/images/ffffffff-ffff-ffff-ffff-ffffffffffff-0.jpg', 0, NOW()),
-- Gaming Mouse
('gggggggg-gggg-gggg-gggg-gggggggggggg', '/images/gggggggg-gggg-gggg-gggg-gggggggggggg-0.jpg', 0, NOW()),
-- Keyboard
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', '/images/hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh-0.jpg', 0, NOW()),
-- Guitar
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '/images/iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii-0.jpg', 0, NOW()),
-- Bicycle
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', '/images/jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj-0.jpg', 0, NOW()),
-- PS5
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', '/images/kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk-0.jpg', 0, NOW()),
-- Drone
('llllllll-llll-llll-llll-llllllllllll', '/images/llllllll-llll-llll-llll-llllllllllll-0.jpg', 0, NOW()),
-- Watch
('mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm', '/images/mmmmmmmm-mmmm-mmmm-mmmm-mmmmmmmmmmmm-0.jpg', 0, NOW());

-- ============================================================================
-- LISTING TAGS
-- ============================================================================
INSERT INTO listing_tags (listing_id, tag) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'laptop'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'apple'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'macbook'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'headphones'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'sony'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'wireless'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'tablet'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'ipad'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'apple-pencil'),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'gaming'),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'mouse'),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'tradeable'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'keyboard'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'mechanical'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'rgb'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'guitar'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'acoustic'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'yamaha'),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'bicycle'),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'mountain-bike'),
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', 'ps5'),
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', 'gaming'),
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', 'console'),
('llllllll-llll-llll-llll-llllllllllll', 'drone'),
('llllllll-llll-llll-llll-llllllllllll', 'dji'),
('llllllll-llll-llll-llll-llllllllllll', 'camera');

-- ============================================================================
-- RATINGS (to establish trust scores)
-- ============================================================================
-- Ratings for student1 (Rahul) - trust score will be calculated by application
-- To achieve ~4.2 trust score: need avg rating ~4.5 with 10+ ratings
-- Bayesian: (3.0*5 + 4.5*10) / (5+10) = (15 + 45) / 15 = 4.0
-- For ~4.2: need avg ~4.6 with 12 ratings
INSERT INTO ratings (from_user_id, to_user_id, listing_id, rating_value, review_comment, timestamp) VALUES
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 5, 'Great seller! Item as described.', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', NULL, 4, 'Reliable trader. Recommended!', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', NULL, 5, 'Good experience.', DATE_SUB(NOW(), INTERVAL 8 DAY)),
('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', NULL, 4, 'Smooth transaction.', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', NULL, 5, 'Excellent!', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111', NULL, 4, 'Very good.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('88888888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', NULL, 5, 'Great!', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('99999999-9999-9999-9999-999999999999', '11111111-1111-1111-1111-111111111111', NULL, 4, 'Recommended.', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- Ratings for student2 (Priya) - trust score will be calculated by application
-- To achieve ~4.5 trust score: need avg rating ~4.7 with 10+ ratings
INSERT INTO ratings (from_user_id, to_user_id, listing_id, rating_value, review_comment, timestamp) VALUES
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 5, 'Excellent product quality!', DATE_SUB(NOW(), INTERVAL 8 DAY)),
('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', NULL, 5, 'Very professional.', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', NULL, 5, 'Highly recommended!', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', NULL, 4, 'Good seller.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('66666666-6666-6666-6666-666666666666', '22222222-2222-2222-2222-222222222222', NULL, 5, 'Excellent!', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('77777777-7777-7777-7777-777777777777', '22222222-2222-2222-2222-222222222222', NULL, 5, 'Great experience!', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', NULL, 4, 'Very good.', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- Ratings for student3 (Arjun) - trust score will be calculated by application
-- To achieve ~4.8 trust score: need avg rating ~4.9 with 10+ ratings
INSERT INTO ratings (from_user_id, to_user_id, listing_id, rating_value, review_comment, timestamp) VALUES
('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 5, 'Perfect condition!', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Great seller, fast response.', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Excellent service!', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Perfect!', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Excellent!', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('77777777-7777-7777-7777-777777777777', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Highly recommended!', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('88888888-8888-8888-8888-888888888888', '33333333-3333-3333-3333-333333333333', NULL, 5, 'Great!', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('99999999-9999-9999-9999-999999999999', '33333333-3333-3333-3333-333333333333', NULL, 4, 'Very good.', NOW());

-- Ratings for other users
INSERT INTO ratings (from_user_id, to_user_id, listing_id, rating_value, review_comment, timestamp) VALUES
('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 4, 'Good item.', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', NULL, 4, 'Fair condition.', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('33333333-3333-3333-3333-333333333333', '66666666-6666-6666-6666-666666666666', NULL, 4, 'As described.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('44444444-4444-4444-4444-444444444444', '77777777-7777-7777-7777-777777777777', NULL, 4, 'Satisfactory.', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- ============================================================================
-- TRADES
-- ============================================================================
-- Pending Trade (user1 wants to trade with user2)
INSERT INTO trades (trade_id, initiator_id, recipient_id, requested_listing_id, cash_adjustment_amount, status, created_at) VALUES
('tttttttt-tttt-tttt-tttt-tttttttttttt', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 500.00, 'PENDING', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- Trade offerings for the pending trade
INSERT INTO trade_offerings (trade_id, listing_id) VALUES
('tttttttt-tttt-tttt-tttt-tttttttttttt', 'iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii');

-- Accepted Trade
INSERT INTO trades (trade_id, initiator_id, recipient_id, requested_listing_id, cash_adjustment_amount, status, created_at, resolved_at) VALUES
('uuuuuuuu-uuuu-uuuu-uuuu-uuuuuuuuuuuu', '44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'gggggggg-gggg-gggg-gggg-gggggggggggg', 0.00, 'ACCEPTED', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY));

-- Rejected Trade
INSERT INTO trades (trade_id, initiator_id, recipient_id, requested_listing_id, cash_adjustment_amount, status, created_at, resolved_at) VALUES
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvvvv', '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 1000.00, 'REJECTED', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY));

-- ============================================================================
-- BIDS
-- ============================================================================
-- Bids for PS5 auction
INSERT INTO bids (listing_id, user_id, bid_amount, bid_time, is_winning) VALUES
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', '11111111-1111-1111-1111-111111111111', 35000.00, DATE_SUB(NOW(), INTERVAL 2 DAY), 0),
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', '22222222-2222-2222-2222-222222222222', 35500.00, DATE_SUB(NOW(), INTERVAL 1 DAY), 0),
('kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', '33333333-3333-3333-3333-333333333333', 36000.00, DATE_SUB(NOW(), INTERVAL 12 HOUR), 1);

-- Bids for Drone auction
INSERT INTO bids (listing_id, user_id, bid_amount, bid_time, is_winning) VALUES
('llllllll-llll-llll-llll-llllllllllll', '44444444-4444-4444-4444-444444444444', 25000.00, DATE_SUB(NOW(), INTERVAL 3 DAY), 0),
('llllllll-llll-llll-llll-llllllllllll', '55555555-5555-5555-5555-555555555555', 26000.00, DATE_SUB(NOW(), INTERVAL 2 DAY), 0),
('llllllll-llll-llll-llll-llllllllllll', '66666666-6666-6666-6666-666666666666', 27000.00, DATE_SUB(NOW(), INTERVAL 1 DAY), 1);

-- ============================================================================
-- WALLET TRANSACTIONS
-- ============================================================================
-- Initial wallet balance transactions
INSERT INTO wallet_transactions (user_id, amount, type, reason, description, timestamp) VALUES
-- Escrow holds for bids
('11111111-1111-1111-1111-111111111111', 36000.00, 'DEBIT', 'ESCROW_HOLD', 'Bid placed on PS5', DATE_SUB(NOW(), INTERVAL 12 HOUR)),
('22222222-2222-2222-2222-222222222222', 35500.00, 'CREDIT', 'ESCROW_RELEASE', 'Outbid on PS5', DATE_SUB(NOW(), INTERVAL 12 HOUR)),
('66666666-6666-6666-6666-666666666666', 27000.00, 'DEBIT', 'ESCROW_HOLD', 'Bid placed on Drone', DATE_SUB(NOW(), INTERVAL 1 DAY)),
-- Trade escrow
('33333333-3333-3333-3333-333333333333', 500.00, 'DEBIT', 'ESCROW_HOLD', 'Trade cash adjustment', DATE_SUB(NOW(), INTERVAL 2 DAY)),
-- Purchase transactions
('22222222-2222-2222-2222-222222222222', 12000.00, 'DEBIT', 'PURCHASE', 'Purchased headphones', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('11111111-1111-1111-1111-111111111111', 12000.00, 'CREDIT', 'PURCHASE', 'Sold headphones', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ============================================================================
-- CHAT MESSAGES
-- ============================================================================
INSERT INTO chat_messages (sender_id, receiver_id, listing_id, message_text, timestamp, is_reported) VALUES
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hi, is the MacBook still available?', DATE_SUB(NOW(), INTERVAL 4 DAY), 0),
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Yes, it is! Are you interested?', DATE_SUB(NOW(), INTERVAL 4 DAY), 0),
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Can we negotiate the price?', DATE_SUB(NOW(), INTERVAL 3 DAY), 0),
('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'Interested in trading for the keyboard.', DATE_SUB(NOW(), INTERVAL 2 DAY), 0);

-- ============================================================================
-- REPORTS
-- ============================================================================
INSERT INTO reports (reporter_id, reported_type, reported_id, reason_text, status, created_at) VALUES
('55555555-5555-5555-5555-555555555555', 'LISTING', 'oooooooo-oooo-oooo-oooo-oooooooooooo', 'This listing appears to contain prohibited content.', 'NEW', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('66666666-6666-6666-6666-666666666666', 'USER', '88888888-8888-8888-8888-888888888888', 'User is not responding to messages.', 'UNDER_REVIEW', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('77777777-7777-7777-7777-777777777777', 'MESSAGE', '1', 'Inappropriate language in chat message.', 'RESOLVED', DATE_SUB(NOW(), INTERVAL 5 DAY));

-- Update resolved report with admin action
UPDATE reports SET 
    admin_action = 'User has been warned. Issue resolved.',
    resolved_at = DATE_SUB(NOW(), INTERVAL 4 DAY)
WHERE report_id = (SELECT report_id FROM (SELECT report_id FROM reports WHERE status = 'RESOLVED' LIMIT 1) AS temp);

-- ============================================================================
-- MODERATION LOGS
-- ============================================================================
INSERT INTO moderation_logs (log_id, listing_id, user_id, predicted_label, confidence, should_flag, admin_action, created_at) VALUES
-- Flagged listing (pending review)
('ml000000-0000-0000-0000-000000000001', 'oooooooo-oooo-oooo-oooo-oooooooooooo', '22222222-2222-2222-2222-222222222222', 'weapon', 0.85, 1, 'PENDING', DATE_SUB(NOW(), INTERVAL 1 DAY)),
-- Approved listing
('ml000000-0000-0000-0000-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'safe', 0.95, 0, 'APPROVED', DATE_SUB(NOW(), INTERVAL 5 DAY)),
-- Rejected listing
('ml000000-0000-0000-0000-000000000003', NULL, '22222222-2222-2222-2222-222222222222', 'drugs', 0.92, 1, 'REJECTED', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- Update approved/rejected logs with admin info
UPDATE moderation_logs SET 
    admin_id = '00000000-0000-0000-0000-000000000001',
    moderation_reason = 'Content reviewed and approved by admin'
WHERE log_id = 'ml000000-0000-0000-0000-000000000002';

UPDATE moderation_logs SET 
    admin_id = '00000000-0000-0000-0000-000000000001',
    moderation_reason = 'Content violates platform policies'
WHERE log_id = 'ml000000-0000-0000-0000-000000000003';

-- ============================================================================
-- WISHLISTS
-- ============================================================================
INSERT INTO wishlists (user_id, listing_id, created_at) VALUES
('22222222-2222-2222-2222-222222222222', 'cccccccc-cccc-cccc-cccc-cccccccccccc', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('33333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('44444444-4444-4444-4444-444444444444', 'kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- ============================================================================
-- FEEDBACKS
-- ============================================================================
INSERT INTO feedbacks (user_id, listing_id, trade_id, type, comment, timestamp) VALUES
('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, 'POST_PURCHASE', 'Great product! Very satisfied with the purchase.', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('11111111-1111-1111-1111-111111111111', NULL, 'uuuuuuuu-uuuu-uuuu-uuuu-uuuuuuuuuuuu', 'POST_TRADE', 'Smooth trade experience. Recommended!', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('33333333-3333-3333-3333-333333333333', 'kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk', NULL, 'POST_BID', 'Excited to participate in this auction!', DATE_SUB(NOW(), INTERVAL 2 DAY));

-- ============================================================================
-- FINAL: Update Trust Scores based on ratings
-- ============================================================================
-- Note: Trust scores are calculated using Bayesian average in the application
-- Formula: (priorMean * priorCount + averageRating * ratingCount) / (priorCount + ratingCount)
-- priorMean = 3.0, priorCount = 5

-- Calculate trust scores from ratings:
-- student1: 8 ratings (5,4,5,4,5,4,5,4) → avg = 4.5 → Bayesian = (15 + 36) / 13 = 3.92
-- student2: 7 ratings (5,5,5,4,5,5,4) → avg = 4.71 → Bayesian = (15 + 32.97) / 12 = 4.0
-- student3: 8 ratings (5,5,5,5,5,5,5,4) → avg = 4.875 → Bayesian = (15 + 39) / 13 = 4.15
-- student4: 1 rating (4) → avg = 4.0 → Bayesian = (15 + 4) / 6 = 3.17
-- student5: 1 rating (4) → avg = 4.0 → Bayesian = (15 + 4) / 6 = 3.17
-- student6: 1 rating (4) → avg = 4.0 → Bayesian = (15 + 4) / 6 = 3.17
-- student7: 1 rating (4) → avg = 4.0 → Bayesian = (15 + 4) / 6 = 3.17

-- Update trust scores to match calculated values
UPDATE users SET trust_score = 3.92 WHERE user_id = '11111111-1111-1111-1111-111111111111';
UPDATE users SET trust_score = 4.0 WHERE user_id = '22222222-2222-2222-2222-222222222222';
UPDATE users SET trust_score = 4.15 WHERE user_id = '33333333-3333-3333-3333-333333333333';
UPDATE users SET trust_score = 3.17 WHERE user_id = '44444444-4444-4444-4444-444444444444';
UPDATE users SET trust_score = 3.17 WHERE user_id = '55555555-5555-5555-5555-555555555555';
UPDATE users SET trust_score = 3.17 WHERE user_id = '66666666-6666-6666-6666-666666666666';
UPDATE users SET trust_score = 3.17 WHERE user_id = '77777777-7777-7777-7777-777777777777';

-- Note: Trust scores will be recalculated when ratings are added through the application
-- For demo purposes, we set them manually to match the Bayesian average calculation

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these to verify the seed data:

-- SELECT COUNT(*) as user_count FROM users;
-- SELECT COUNT(*) as listing_count FROM listings;
-- SELECT COUNT(*) as active_listings FROM listings WHERE is_active = 1;
-- SELECT COUNT(*) as tradeable_listings FROM listings WHERE is_tradeable = 1;
-- SELECT COUNT(*) as biddable_listings FROM listings WHERE is_biddable = 1;
-- SELECT COUNT(*) as rating_count FROM ratings;
-- SELECT COUNT(*) as trade_count FROM trades;
-- SELECT COUNT(*) as bid_count FROM bids;
-- SELECT COUNT(*) as moderation_log_count FROM moderation_logs;

SELECT 'Seed data insertion completed!' as status;

