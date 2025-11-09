-- Migration Script: Update domain from @pilani.bits-pilani.com to @pilani.bits-pilani.ac.in
-- Run this script to update all existing user emails in the database

USE tradenbysell;

-- Update all user emails from @pilani.bits-pilani.com to @pilani.bits-pilani.ac.in
UPDATE users 
SET email = REPLACE(email, '@pilani.bits-pilani.com', '@pilani.bits-pilani.ac.in')
WHERE email LIKE '%@pilani.bits-pilani.com';

-- Verify the update
SELECT email, full_name, role FROM users WHERE email LIKE '%@pilani.bits-pilani.ac.in' LIMIT 10;

-- Show count of updated users
SELECT COUNT(*) as updated_users FROM users WHERE email LIKE '%@pilani.bits-pilani.ac.in';

