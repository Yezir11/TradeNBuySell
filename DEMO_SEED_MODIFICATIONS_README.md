# Demo Seed SQL Modifications

## Summary

The `demo_tradenbuyseed_v3.sql` file has been modified to:
1. ✅ **Add user verification** - Checks that all required users exist before inserting listings
2. ✅ **Fix image paths** - Changed from `/demo-images/` to `/images/` to match the backend configuration
3. ✅ **Backup script created** - Script to backup current data before running the seed file

## Files Created/Modified

### 1. Modified SQL File
- **File**: `demo_tradenbuyseed_v3_modified.sql`
- **Changes**:
  - Added user verification section (lines 18-58)
  - All image paths changed from `/demo-images/` to `/images/`
  - All other data remains unchanged

### 2. Backup Script
- **File**: `scripts/backup-current-data.sh`
- **Purpose**: Exports all current database data before running the seed file
- **Usage**: 
  ```bash
  ./scripts/backup-current-data.sh
  ```
- **Output**: Creates a backup file in `backups/database_backup_TIMESTAMP.sql`

### 3. Modification Script
- **File**: `scripts/modify-demo-seed-sql.py`
- **Purpose**: Python script that was used to modify the SQL file
- **Note**: Already executed, but kept for reference

## Required Users

The script requires the following 22 user IDs to exist in the `users` table:

1. `025b0b6f-085f-4fc2-972d-e194b3841f24`
2. `0337b153-c6c0-45cf-8745-82681b240d4d`
3. `04254252-9e56-41b7-91f2-ef60b768f8eb`
4. `05c8d39e-a787-4261-b17c-5ed4cf2275b3`
5. `05db736d-d6b1-4219-aaa9-b3d0f28fe152`
6. `077cfdd8-8b2a-41bc-8da8-26d786c00c81`
7. `0971b08d-3fa5-4db4-a37d-8e7ba5c82aac`
8. `0a30279a-704b-451d-bb6b-2f369e580a7d`
9. `0d39b2fc-cdc0-4219-8914-a1402f6543b2`
10. `0e1e6311-136c-4bdc-a3a6-522f78ec9d67`
11. `0f1e885f-15f7-4b32-8f87-267cf39c8b79`
12. `148d4af4-6756-484f-b1a0-90251cca0b2a`
13. `1564a25e-5bb0-46f0-9ae7-1f7361d7877a`
14. `15f726f9-f0b8-4c49-a6bc-fd2ef03eba75`
15. `174acb10-d7db-45ae-976c-5eab73b315aa`
16. `197d226f-27ad-4a6d-a269-f1766f3c8b5f`
17. `1c1c7d53-1d9e-447b-843a-d3c28b0bedeb`
18. `1e589da4-7c25-4455-986f-d7b112854c4c`
19. `1e63154a-2733-41c9-a27d-3cbf184f320b`
20. `226beb04-4f24-4919-8b7b-99cf23029e1a`
21. `22e9a5df-204e-4379-9310-0793c339bbcb`
22. `234a49f0-3135-48d8-8ef8-9cfe73e8bb87`

## Usage Instructions

### Step 1: Backup Current Data
```bash
cd /Users/vaibhavvyas/Desktop/SEMProject
./scripts/backup-current-data.sh
```

### Step 2: Verify Users Exist
Before running the modified SQL file, ensure all 22 required users exist in your database. You can check with:
```sql
SELECT user_id FROM users WHERE user_id IN (
  '025b0b6f-085f-4fc2-972d-e194b3841f24',
  '0337b153-c6c0-45cf-8745-82681b240d4d',
  -- ... (all 22 user IDs)
);
```

### Step 3: Run the Modified SQL File
```bash
mysql -h localhost -P 3306 -u root -proot tradenbysell < demo_tradenbuyseed_v3_modified.sql
```

## What Gets Replaced

The script will **TRUNCATE** (delete all data from) the following tables:
- `moderation_logs`
- `wallet_transactions`
- `transaction_history`
- `chat_messages`
- `ratings`
- `feedbacks`
- `trade_offerings`
- `trades`
- `bids`
- `wishlists`
- `listing_tags`
- `listing_images`
- `listings`

**Note**: The `users` table is **NOT** truncated, so existing users are preserved.

## Image Path Changes

All image URLs have been changed from:
- **Old**: `/demo-images/filename.jpg`
- **New**: `/images/filename.jpg`

This matches the backend configuration where images are served via `/images/**` endpoint (configured in `WebConfig.java`).

## Restoring from Backup

If you need to restore the previous data:
```bash
mysql -h localhost -P 3306 -u root -proot tradenbysell < backups/database_backup_TIMESTAMP.sql
```

## Important Notes

1. ⚠️ **Data Loss Warning**: Running this script will delete all existing listings, bids, trades, ratings, etc. Make sure to backup first!

2. ⚠️ **User Verification**: The script checks for required users but does not automatically stop execution if they're missing. Check the verification result message before proceeding.

3. ⚠️ **Image Files**: The script updates image paths in the database, but you must ensure the actual image files exist in the `backend/uploads/` directory (or wherever your `app.upload.dir` points to).

4. ✅ **Schema Compatible**: The modified SQL file is fully compatible with the current database schema.

