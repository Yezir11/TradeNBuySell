-- TradeNBuySell Database Schema
-- This file contains all table definitions for the TradeNBuySell application

USE tradenbysell;

-- Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('ADMIN','STUDENT') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STUDENT',
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `wallet_balance` decimal(15,2) NOT NULL DEFAULT '1000.00',
  `trust_score` float DEFAULT '0',
  `registered_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `is_suspended` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_trust_score` (`trust_score`),
  KEY `idx_suspended` (`is_suspended`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listings Table
CREATE TABLE IF NOT EXISTS `listings` (
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `is_tradeable` tinyint(1) DEFAULT '0',
  `is_biddable` tinyint(1) DEFAULT '0',
  `starting_price` decimal(15,2) DEFAULT NULL,
  `bid_increment` decimal(15,2) DEFAULT NULL,
  `bid_start_time` timestamp NULL DEFAULT NULL,
  `bid_end_time` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`listing_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category` (`category`),
  KEY `idx_active` (`is_active`),
  KEY `idx_biddable` (`is_biddable`),
  KEY `idx_tradeable` (`is_tradeable`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `listings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listing Images Table
CREATE TABLE IF NOT EXISTS `listing_images` (
  `image_id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  KEY `idx_listing_id` (`listing_id`),
  CONSTRAINT `listing_images_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listing Tags Table
CREATE TABLE IF NOT EXISTS `listing_tags` (
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tag` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`listing_id`,`tag`),
  KEY `idx_tag` (`tag`),
  CONSTRAINT `listing_tags_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wallet Transactions Table
CREATE TABLE IF NOT EXISTS `wallet_transactions` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `type` enum('CREDIT','DEBIT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` enum('PURCHASE','TRADE','BID','REFUND','TOPUP','WITHDRAWAL','ESCROW_HOLD','ESCROW_RELEASE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_reference_id` (`reference_id`),
  KEY `idx_timestamp` (`timestamp`),
  CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trades Table
CREATE TABLE IF NOT EXISTS `trades` (
  `trade_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `initiator_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cash_adjustment_amount` decimal(15,2) DEFAULT '0.00',
  `status` enum('PENDING','ACCEPTED','REJECTED','COMPLETED','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`trade_id`),
  KEY `idx_initiator_id` (`initiator_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_requested_listing_id` (`requested_listing_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `trades_ibfk_1` FOREIGN KEY (`initiator_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `trades_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `trades_ibfk_3` FOREIGN KEY (`requested_listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trade Offerings Table
CREATE TABLE IF NOT EXISTS `trade_offerings` (
  `trade_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`trade_id`,`listing_id`),
  CONSTRAINT `trade_offerings_ibfk_1` FOREIGN KEY (`trade_id`) REFERENCES `trades` (`trade_id`) ON DELETE CASCADE,
  CONSTRAINT `trade_offerings_ibfk_2` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bids Table
CREATE TABLE IF NOT EXISTS `bids` (
  `bid_id` bigint NOT NULL AUTO_INCREMENT,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bid_amount` decimal(15,2) NOT NULL,
  `bid_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_winning` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`bid_id`),
  KEY `idx_listing_id` (`listing_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_bid_time` (`bid_time`),
  KEY `idx_winning` (`is_winning`),
  CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE,
  CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS `chat_messages` (
  `message_id` bigint NOT NULL AUTO_INCREMENT,
  `sender_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_reported` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`message_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_listing` (`listing_id`),
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ratings Table
CREATE TABLE IF NOT EXISTS `ratings` (
  `rating_id` bigint NOT NULL AUTO_INCREMENT,
  `from_user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating_value` int NOT NULL,
  `review_comment` text COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  KEY `idx_from_user_id` (`from_user_id`),
  KEY `idx_to_user_id` (`to_user_id`),
  KEY `idx_listing_id` (`listing_id`),
  CONSTRAINT `ratings_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ratings_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ratings_ibfk_3` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reports Table
CREATE TABLE IF NOT EXISTS `reports` (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `reporter_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reported_type` enum('LISTING','USER','MESSAGE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reported_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('NEW','UNDER_REVIEW','RESOLVED','ESCALATED','DISMISSED') COLLATE utf8mb4_unicode_ci DEFAULT 'NEW',
  `admin_action` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `idx_reporter_id` (`reporter_id`),
  KEY `idx_reported_type` (`reported_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wishlists Table
CREATE TABLE IF NOT EXISTS `wishlists` (
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`listing_id`),
  CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Feedbacks Table
CREATE TABLE IF NOT EXISTS `feedbacks` (
  `feedback_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trade_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('POST_PURCHASE','POST_TRADE','POST_BID','GENERAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_listing_id` (`listing_id`),
  KEY `idx_trade_id` (`trade_id`),
  KEY `idx_type` (`type`),
  KEY `idx_timestamp` (`timestamp`),
  CONSTRAINT `feedbacks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `feedbacks_ibfk_2` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE SET NULL,
  CONSTRAINT `feedbacks_ibfk_3` FOREIGN KEY (`trade_id`) REFERENCES `trades` (`trade_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories Table (if used)
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transaction History Table (if used)
CREATE TABLE IF NOT EXISTS `transaction_history` (
  `transaction_history_id` bigint NOT NULL AUTO_INCREMENT,
  `trade_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bid_id` bigint DEFAULT NULL,
  `from_user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT NULL,
  `transaction_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_history_id`),
  KEY `idx_trade_id` (`trade_id`),
  KEY `idx_bid_id` (`bid_id`),
  CONSTRAINT `transaction_history_ibfk_1` FOREIGN KEY (`trade_id`) REFERENCES `trades` (`trade_id`) ON DELETE SET NULL,
  CONSTRAINT `transaction_history_ibfk_2` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`bid_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
