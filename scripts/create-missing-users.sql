-- Create missing users required by demo_tradenbuyseed_v3_modified.sql
-- These users will be created with default values

SET @password_hash = '$2a$10$MB5roPLO3RjnGNifzSBDCO9v.66TawwbFg2s9cLHT6qDJ.LwROZ.G';

-- Insert users only if they don't exist
INSERT IGNORE INTO users (user_id, email, password_hash, role, full_name, wallet_balance, trust_score, registered_at, is_suspended) VALUES
('025b0b6f-085f-4fc2-972d-e194b3841f24', 'demo_user_1@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 1', 1000.00, 0.0, NOW(), 0),
('0337b153-c6c0-45cf-8745-82681b240d4d', 'demo_user_2@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 2', 1000.00, 0.0, NOW(), 0),
('04254252-9e56-41b7-91f2-ef60b768f8eb', 'demo_user_3@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 3', 1000.00, 0.0, NOW(), 0),
('05c8d39e-a787-4261-b17c-5ed4cf2275b3', 'demo_user_4@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 4', 1000.00, 0.0, NOW(), 0),
('05db736d-d6b1-4219-aaa9-b3d0f28fe152', 'demo_user_5@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 5', 1000.00, 0.0, NOW(), 0),
('077cfdd8-8b2a-41bc-8da8-26d786c00c81', 'demo_user_6@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 6', 1000.00, 0.0, NOW(), 0),
('0971b08d-3fa5-4db4-a37d-8e7ba5c82aac', 'demo_user_7@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 7', 1000.00, 0.0, NOW(), 0),
('0a30279a-704b-451d-bb6b-2f369e580a7d', 'demo_user_8@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 8', 1000.00, 0.0, NOW(), 0),
('0d39b2fc-cdc0-4219-8914-a1402f6543b2', 'demo_user_9@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 9', 1000.00, 0.0, NOW(), 0),
('0e1e6311-136c-4bdc-a3a6-522f78ec9d67', 'demo_user_10@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 10', 1000.00, 0.0, NOW(), 0),
('0f1e885f-15f7-4b32-8f87-267cf39c8b79', 'demo_user_11@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 11', 1000.00, 0.0, NOW(), 0),
('148d4af4-6756-484f-b1a0-90251cca0b2a', 'demo_user_12@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 12', 1000.00, 0.0, NOW(), 0),
('1564a25e-5bb0-46f0-9ae7-1f7361d7877a', 'demo_user_13@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 13', 1000.00, 0.0, NOW(), 0),
('15f726f9-f0b8-4c49-a6bc-fd2ef03eba75', 'demo_user_14@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 14', 1000.00, 0.0, NOW(), 0),
('174acb10-d7db-45ae-976c-5eab73b315aa', 'demo_user_15@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 15', 1000.00, 0.0, NOW(), 0),
('197d226f-27ad-4a6d-a269-f1766f3c8b5f', 'demo_user_16@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 16', 1000.00, 0.0, NOW(), 0),
('1c1c7d53-1d9e-447b-843a-d3c28b0bedeb', 'demo_user_17@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 17', 1000.00, 0.0, NOW(), 0),
('1e589da4-7c25-4455-986f-d7b112854c4c', 'demo_user_18@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 18', 1000.00, 0.0, NOW(), 0),
('1e63154a-2733-41c9-a27d-3cbf184f320b', 'demo_user_19@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 19', 1000.00, 0.0, NOW(), 0),
('226beb04-4f24-4919-8b7b-99cf23029e1a', 'demo_user_20@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 20', 1000.00, 0.0, NOW(), 0),
('22e9a5df-204e-4379-9310-0793c339bbcb', 'demo_user_21@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 21', 1000.00, 0.0, NOW(), 0),
('234a49f0-3135-48d8-8ef8-9cfe73e8bb87', 'demo_user_22@pilani.bits-pilani.ac.in', @password_hash, 'STUDENT', 'Demo User 22', 1000.00, 0.0, NOW(), 0);

