-- Migration: Add message_type and offer_id columns to chat_messages table
USE tradenbysell;

-- Add message_type column if it doesn't exist
SET @dbname = DATABASE();
SET @tablename = 'chat_messages';
SET @colname1 = 'message_type';
SET @colname2 = 'offer_id';

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE table_schema = @dbname 
   AND table_name = @tablename 
   AND column_name = @colname1) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN `', @colname1, '` VARCHAR(50) NULL AFTER `message_text`')
));
PREPARE alterTable1 FROM @preparedStatement;
EXECUTE alterTable1;
DEALLOCATE PREPARE alterTable1;

-- Add offer_id column if it doesn't exist
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE table_schema = @dbname 
   AND table_name = @tablename 
   AND column_name = @colname2) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN `', @colname2, '` CHAR(36) NULL AFTER `message_type`')
));
PREPARE alterTable2 FROM @preparedStatement;
EXECUTE alterTable2;
DEALLOCATE PREPARE alterTable2;

-- Add indexes if they don't exist
SET @indexname1 = 'idx_message_type';
SET @indexname2 = 'idx_offer_id';

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
   WHERE table_schema = @dbname 
   AND table_name = @tablename 
   AND index_name = @indexname1) > 0,
  'SELECT 1',
  CONCAT('CREATE INDEX ', @indexname1, ' ON ', @tablename, ' (message_type)')
));
PREPARE createIndex1 FROM @preparedStatement;
EXECUTE createIndex1;
DEALLOCATE PREPARE createIndex1;

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
   WHERE table_schema = @dbname 
   AND table_name = @tablename 
   AND index_name = @indexname2) > 0,
  'SELECT 1',
  CONCAT('CREATE INDEX ', @indexname2, ' ON ', @tablename, ' (offer_id)')
));
PREPARE createIndex2 FROM @preparedStatement;
EXECUTE createIndex2;
DEALLOCATE PREPARE createIndex2;

-- Add foreign key constraint if it doesn't exist
SET @fkname = 'chat_messages_ibfk_4';
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
   WHERE table_schema = @dbname 
   AND table_name = @tablename 
   AND constraint_name = @fkname) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD CONSTRAINT ', @fkname, 
         ' FOREIGN KEY (offer_id) REFERENCES purchase_offers (offer_id) ON DELETE SET NULL')
));
PREPARE createFK FROM @preparedStatement;
EXECUTE createFK;
DEALLOCATE PREPARE createFK;
