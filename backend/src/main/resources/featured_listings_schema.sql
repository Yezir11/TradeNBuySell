-- Featured Listings Schema
-- This adds featured listing functionality to the TradeNBuySell application

USE tradenbysell;

-- Add featured listing fields to listings table
ALTER TABLE `listings` 
ADD COLUMN `is_featured` tinyint(1) DEFAULT '0' AFTER `is_active`,
ADD COLUMN `featured_until` timestamp NULL DEFAULT NULL AFTER `is_featured`,
ADD COLUMN `featured_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `featured_until`,
ADD INDEX `idx_is_featured` (`is_featured`),
ADD INDEX `idx_featured_until` (`featured_until`);

-- Create featured packages table for pricing
CREATE TABLE IF NOT EXISTS `featured_packages` (
  `package_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `package_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `display_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`package_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default featured packages
INSERT INTO `featured_packages` (`package_id`, `package_name`, `duration_days`, `price`, `description`, `is_active`, `display_order`) VALUES
('featured_7d', 'Featured Listing - 7 Days', 7, 50.00, 'Get your listing featured at the top for 7 days. Increases visibility by 5x.', 1, 1),
('featured_30d', 'Featured Listing - 30 Days', 30, 150.00, 'Get your listing featured at the top for 30 days. Best value for long-term listings.', 1, 2),
('top_featured_7d', 'Top Featured - 7 Days', 7, 100.00, 'Premium placement at the very top of featured listings for 7 days.', 1, 3),
('top_featured_30d', 'Top Featured - 30 Days', 30, 300.00, 'Premium placement at the very top of featured listings for 30 days. Maximum visibility.', 1, 4);

-- Update wallet_transactions reason enum to include FEATURED_LISTING
ALTER TABLE `wallet_transactions` 
MODIFY COLUMN `reason` enum('PURCHASE','TRADE','BID','REFUND','TOPUP','WITHDRAWAL','ESCROW_HOLD','ESCROW_RELEASE','FEATURED_LISTING') COLLATE utf8mb4_unicode_ci NOT NULL;

