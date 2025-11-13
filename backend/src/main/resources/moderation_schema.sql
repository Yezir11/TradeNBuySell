-- Moderation Logs Table for ML-based content moderation
USE tradenbysell;

CREATE TABLE IF NOT EXISTS `moderation_logs` (
  `log_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `listing_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `predicted_label` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `confidence` decimal(5,4) NOT NULL,
  `should_flag` tinyint(1) DEFAULT '0',
  `admin_action` enum('APPROVED','REJECTED','PENDING','BLACKLISTED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `admin_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `moderation_reason` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_heatmap` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `text_explanation` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_listing_id` (`listing_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_predicted_label` (`predicted_label`),
  KEY `idx_should_flag` (`should_flag`),
  KEY `idx_admin_action` (`admin_action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `moderation_logs_ibfk_1` FOREIGN KEY (`listing_id`) REFERENCES `listings` (`listing_id`) ON DELETE SET NULL,
  CONSTRAINT `moderation_logs_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `moderation_logs_ibfk_3` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

