-- Quick fix: Add missing columns to chat_messages table
-- Run this directly in MySQL

USE tradenbysell;

ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS message_type varchar(50) DEFAULT NULL AFTER message_text,
ADD COLUMN IF NOT EXISTS offer_id char(36) DEFAULT NULL AFTER message_type,
ADD COLUMN IF NOT EXISTS trade_id char(36) DEFAULT NULL AFTER offer_id,
ADD COLUMN IF NOT EXISTS is_read tinyint(1) DEFAULT 0 AFTER is_reported,
ADD COLUMN IF NOT EXISTS read_at timestamp NULL DEFAULT NULL AFTER is_read;

-- Note: MySQL doesn't support "ADD COLUMN IF NOT EXISTS" syntax
-- So if you get errors about columns already existing, that's fine - they're already there

