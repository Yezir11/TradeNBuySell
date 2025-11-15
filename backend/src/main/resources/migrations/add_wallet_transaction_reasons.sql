-- Migration: Add missing enum values to wallet_transactions.reason column
-- This adds 'SALE' and 'FEATURED_LISTING' to match the Java TransactionReason enum

USE tradenbysell;

-- Note: MySQL does not support ALTER TABLE to add enum values directly
-- We need to modify the column definition to include the new values
ALTER TABLE `wallet_transactions` 
MODIFY COLUMN `reason` enum('PURCHASE','SALE','TRADE','BID','REFUND','TOPUP','WITHDRAWAL','ESCROW_HOLD','ESCROW_RELEASE','FEATURED_LISTING') 
COLLATE utf8mb4_unicode_ci NOT NULL;

