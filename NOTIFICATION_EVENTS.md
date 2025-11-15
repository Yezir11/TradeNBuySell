# Notification Events - TradeNBuySell Platform

This document outlines all possible events that should generate notifications for users (students) and admins.

---

## 📱 **For Students/Regular Users**

### 🏷️ **Listing-Related Notifications**

1. **Listing Moderation**
   - `LISTING_FLAGGED` - Your listing was flagged by ML moderation and is pending admin review
   - `LISTING_APPROVED` - Your flagged listing has been approved by admin and is now active
   - `LISTING_REJECTED` - Your flagged listing has been rejected by admin
   - `LISTING_DEACTIVATED` - Your listing has been deactivated (manual or automatic)

2. **Listing Status Changes**
   - `LISTING_FEATURED` - Your listing has been featured and will appear at the top
   - `LISTING_FEATURE_EXPIRED` - Your listing's featured status has expired
   - `LISTING_EDITED` - Your listing edit created a new listing (old one deactivated)

3. **Listing Interactions**
   - `LISTING_VIEWED` - Someone viewed your listing (optional - for analytics)
   - `LISTING_ADDED_TO_WISHLIST` - Someone added your listing to their wishlist (optional)

---

### 💰 **Bidding-Related Notifications**

4. **Bid Events**
   - `NEW_BID_RECEIVED` - Someone placed a bid on your biddable listing
   - `BID_OUTBID` - Your bid was outbid by another user
   - `BID_WON` - You won the bid on a listing
   - `BID_LOST` - You lost the bid (someone else won)
   - `BID_FINALIZED` - Listing owner finalized your winning bid
   - `BIDDING_ENDING_SOON` - Bidding on a listing you bid on is ending soon (e.g., 1 hour remaining)
   - `BIDDING_ENDED` - Bidding on a listing you bid on has ended

---

### 🤝 **Trade-Related Notifications**

5. **Trade Proposals**
   - `TRADE_PROPOSED` - Someone proposed a trade involving your listing
   - `TRADE_ACCEPTED` - Your trade proposal was accepted
   - `TRADE_REJECTED` - Your trade proposal was rejected
   - `TRADE_CANCELLED` - A trade you were involved in was cancelled
   - `TRADE_COMPLETED` - Trade has been completed successfully (both parties notified)
   - `TRADE_ASK_NEW_PROPOSAL` - Recipient asked for a new trade proposal

---

### 💵 **Purchase Offer Notifications**

6. **Purchase Offers**
   - `PURCHASE_OFFER_RECEIVED` - Someone made a purchase offer on your listing
   - `PURCHASE_OFFER_ACCEPTED` - Your purchase offer was accepted by the seller
   - `PURCHASE_OFFER_REJECTED` - Your purchase offer was rejected
   - `PURCHASE_OFFER_COUNTERED` - Seller countered your purchase offer with a new amount
   - `COUNTER_OFFER_ACCEPTED` - Buyer accepted your counter offer
   - `PURCHASE_COMPLETED` - Purchase transaction completed successfully

---

### 💬 **Chat & Communication Notifications**

7. **Chat Messages**
   - `NEW_MESSAGE` - You received a new chat message (if not already in chat)
   - `MESSAGE_READ` - Your message was read by the recipient (optional - for read receipts)

---

### 💳 **Wallet & Transaction Notifications**

8. **Wallet Transactions**
   - `WALLET_CREDITED` - Funds credited to your wallet (sale, trade, refund, etc.)
   - `WALLET_DEBITED` - Funds debited from your wallet (purchase, trade, bid, etc.)
   - `INSUFFICIENT_FUNDS` - Transaction failed due to insufficient wallet balance
   - `LARGE_TRANSACTION` - Large transaction alert (e.g., > ₹10,000) for security

9. **Transaction Types to Notify**
   - Sale completed (credit)
   - Purchase completed (debit)
   - Trade cash adjustment (credit/debit)
   - Bid won payment (debit)
   - Bid won receipt (credit)
   - Refund received (credit)
   - Top-up successful (credit)
   - Featured listing payment (debit)

---

### ⭐ **Trust Score & Rating Notifications**

10. **Trust Score Updates**
    - `TRUST_SCORE_UPDATED` - Your trust score has been updated after receiving a rating
    - `RATING_RECEIVED` - You received a new rating from a completed transaction (anonymous)
    - `RATING_REMINDER` - Reminder to rate the other party after a completed transaction

---

### 👤 **Account & Security Notifications**

11. **Account Management**
    - `ACCOUNT_SUSPENDED` - Your account has been suspended by admin
    - `ACCOUNT_REACTIVATED` - Your account has been reactivated
    - `PASSWORD_CHANGED` - Your password was changed (security notification)
    - `LOGIN_FROM_NEW_DEVICE` - Login detected from a new device/IP (security)

---

### 📊 **System & Feature Notifications**

12. **System Updates**
    - `FEATURE_ANNOUNCEMENT` - New feature announcement
    - `MAINTENANCE_SCHEDULED` - Scheduled maintenance notification
    - `POLICY_UPDATE` - Terms of service or policy update

---

## 👨‍💼 **For Admins**

### 🚨 **Moderation Notifications**

1. **Content Moderation**
   - `NEW_FLAGGED_LISTING` - New listing flagged by ML moderation requires review
   - `FLAGGED_LISTING_COUNT` - Daily/weekly summary of flagged listings pending review
   - `MODERATION_BACKLOG_ALERT` - Too many pending moderation reviews (threshold alert)

---

### 📝 **Report Notifications**

2. **User Reports**
   - `NEW_REPORT_SUBMITTED` - New report submitted by a user
   - `REPORT_URGENT` - Urgent report requiring immediate attention
   - `REPORT_RESOLVED` - Report you were handling has been resolved

---

### 👥 **User Management Notifications**

3. **User Activity**
   - `NEW_USER_REGISTERED` - New user registration (optional - for monitoring)
   - `SUSPICIOUS_ACTIVITY` - Suspicious user activity detected (multiple flags, reports, etc.)
   - `HIGH_VALUE_TRANSACTION` - Large transaction detected (e.g., > ₹50,000)
   - `MULTIPLE_REPORTS_ON_USER` - User has received multiple reports

---

### ⚙️ **System Administration**

4. **System Alerts**
   - `ML_MODERATION_API_DOWN` - ML moderation API is not responding
   - `DATABASE_ERROR` - Database connection issues
   - `HIGH_ERROR_RATE` - High error rate detected in system
   - `BACKUP_COMPLETED` - Daily backup completed successfully
   - `BACKUP_FAILED` - Backup failed and requires attention

---

### 📈 **Analytics & Insights**

5. **Platform Metrics** (Optional - for admin dashboard)
   - `DAILY_SUMMARY` - Daily platform activity summary
   - `WEEKLY_REPORT` - Weekly platform statistics
   - `MONTHLY_REPORT` - Monthly platform statistics

---

## 🎯 **Notification Priority Levels**

### **High Priority** (Immediate notification, sound/vibration)
- Account suspended
- Large transactions
- Trade/purchase completed
- Bid won/lost
- Insufficient funds

### **Medium Priority** (Notification, no sound)
- New bid received
- Trade proposal received
- Purchase offer received
- Listing flagged/approved/rejected
- New message (if not in chat)

### **Low Priority** (Silent notification, badge only)
- Trust score updated
- Listing viewed
- Feature announcements
- System updates

---

## 📋 **Notification Delivery Methods**

1. **In-App Notifications** (Primary)
   - Notification center/bell icon
   - Real-time updates via WebSocket or polling
   - Badge count for unread notifications

2. **Email Notifications** (Optional - for important events)
   - Account suspension
   - Large transactions
   - Trade/purchase completed
   - Bid won

3. **Push Notifications** (Future - mobile app)
   - Critical events only
   - User-configurable preferences

---

## 🔔 **Notification Preferences**

Users should be able to configure:
- Which notification types they want to receive
- Email notification preferences
- Push notification preferences
- Quiet hours (no notifications during specific times)
- Frequency limits (e.g., max 1 notification per hour for listing views)

---

## 📊 **Notification Data Model**

Each notification should include:
- `notificationId` - Unique identifier
- `userId` - Recipient user ID
- `type` - Notification type (enum from above)
- `title` - Notification title
- `message` - Notification message/body
- `relatedEntityId` - ID of related entity (listingId, tradeId, offerId, etc.)
- `relatedEntityType` - Type of related entity (LISTING, TRADE, OFFER, etc.)
- `isRead` - Read status
- `readAt` - Timestamp when read
- `priority` - HIGH, MEDIUM, LOW
- `createdAt` - Timestamp when notification was created
- `metadata` - Additional JSON data (e.g., amount, listing title, etc.)

---

## 🚀 **Implementation Priority**

### **Phase 1 (Essential)**
1. Trade-related notifications (proposed, accepted, rejected, completed)
2. Purchase offer notifications (received, accepted, rejected, countered)
3. Bid notifications (new bid, outbid, won, lost, finalized)
4. Listing moderation notifications (flagged, approved, rejected)
5. Wallet transaction notifications (credits, debits)

### **Phase 2 (Important)**
6. Chat message notifications
7. Trust score updates
8. Account management notifications
9. Admin moderation notifications

### **Phase 3 (Nice to Have)**
10. Listing interactions (views, wishlist)
11. System announcements
12. Analytics notifications
13. Email notifications
14. Push notifications

---

## 📝 **Notes**

- Notifications should be non-intrusive but visible
- Users should be able to mark notifications as read/unread
- Notifications should be grouped by type or time
- Old notifications should be archived (e.g., after 30 days)
- Admin notifications should be separate from user notifications
- Consider rate limiting to prevent notification spam

