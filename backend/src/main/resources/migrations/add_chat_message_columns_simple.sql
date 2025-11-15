-- Migration: Add missing columns to chat_messages table
-- Simple version that can be run manually in MySQL

USE tradenbysell;

-- Check and add message_type column
SET @exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_schema = 'tradenbysell' 
  AND table_name = 'chat_messages' 
  AND column_name = 'message_type');
SET @sql = IF(@exists = 0, 
  'ALTER TABLE chat_messages ADD COLUMN message_type varchar(50) DEFAULT NULL AFTER message_text',
  'SELECT "Column message_type already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add offer_id column
SET @exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_schema = 'tradenbysell' 
  AND table_name = 'chat_messages' 
  AND column_name = 'offer_id');
SET @sql = IF(@exists = 0, 
  'ALTER TABLE chat_messages ADD COLUMN offer_id char(36) DEFAULT NULL AFTER message_type',
  'SELECT "Column offer_id already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add trade_id column
SET @exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_schema = 'tradenbysell' 
  AND table_name = 'chat_messages' 
  AND column_name = 'trade_id');
SET @sql = IF(@exists = 0, 
  'ALTER TABLE chat_messages ADD COLUMN trade_id char(36) DEFAULT NULL AFTER offer_id',
  'SELECT "Column trade_id already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add is_read column
SET @exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_schema = 'tradenbysell' 
  AND table_name = 'chat_messages' 
  AND column_name = 'is_read');
SET @sql = IF(@exists = 0, 
  'ALTER TABLE chat_messages ADD COLUMN is_read tinyint(1) DEFAULT 0 AFTER is_reported',
  'SELECT "Column is_read already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add read_at column
SET @exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_schema = 'tradenbysell' 
  AND table_name = 'chat_messages' 
  AND column_name = 'read_at');
SET @sql = IF(@exists = 0, 
  'ALTER TABLE chat_messages ADD COLUMN read_at timestamp NULL DEFAULT NULL AFTER is_read',
  'SELECT "Column read_at already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update existing rows to set is_read = 0
UPDATE chat_messages SET is_read = 0 WHERE is_read IS NULL;

SELECT 'Migration completed successfully!' as status;

