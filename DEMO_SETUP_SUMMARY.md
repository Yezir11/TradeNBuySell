# Demo Setup Summary

## ✅ What Has Been Created

### 1. Database Seed Data (`backend/src/main/resources/seed_data.sql`)
- **10 Users:**
  - 1 Admin user
  - 9 Student users with varying trust scores
  - All users use password: `password123`
  - BCrypt hash: `$2a$10$MB5roPLO3RjnGNifzSBDCO9v.66TawwbFg2s9cLHT6qDJ.LwROZ.G`

- **15+ Listings:**
  - Regular purchase listings (Electronics, Furniture, Books)
  - Tradeable listings (Gaming Mouse, Keyboard, Guitar, Bicycle)
  - Biddable listings (PS5, Drone, Watch) with auction details
  - Inactive listings (sold items, flagged items)

- **20+ Ratings:**
  - Ratings for student1 (8 ratings) → Trust Score: ~3.92
  - Ratings for student2 (7 ratings) → Trust Score: ~4.0
  - Ratings for student3 (8 ratings) → Trust Score: ~4.15
  - Ratings for other users

- **3 Trades:**
  - 1 Pending trade (student3 → student2)
  - 1 Accepted trade (student4 → student1)
  - 1 Rejected trade (student5 → student3)

- **6 Bids:**
  - 3 bids on PS5 auction
  - 3 bids on Drone auction
  - Winning bids highlighted

- **3 Moderation Logs:**
  - 1 Pending (flagged listing)
  - 1 Approved (safe listing)
  - 1 Rejected (prohibited content)

- **3 Reports:**
  - 1 New (listing report)
  - 1 Under Review (user report)
  - 1 Resolved (message report)

- **4 Chat Messages:**
  - Messages between users about listings

- **3 Wishlists:**
  - Users have items in their wishlists

- **3 Feedbacks:**
  - Post-purchase, post-trade, post-bid feedbacks

- **Wallet Transactions:**
  - Escrow holds for bids
  - Trade escrow
  - Purchase transactions

### 2. Setup Script (`scripts/setup-demo.sh`)
- Automated database setup
- Creates database and schema
- Inserts seed data
- Verifies data insertion

### 3. Demo Guide (`DEMO_GUIDE.md`)
- Complete setup instructions
- Demo user credentials
- Demo flow walkthrough
- Troubleshooting guide

### 4. Documentation
- Trust score calculation explanation
- Bayesian average formula
- Demo data overview

## 🚀 Quick Start

```bash
# 1. Setup database
./scripts/setup-demo.sh

# 2. Start backend
cd backend && mvn spring-boot:run

# 3. Start frontend
cd frontend && npm start

# 4. Start ML moderation (optional)
cd ml-moderation && python api/app.py
```

## 👥 Demo Users

**All users use password: `password123`**

| Email | Role | Trust Score | Wallet | Can Trade |
|-------|------|-------------|--------|-----------|
| admin@pilani.bits-pilani.ac.in | ADMIN | 5.0 | ₹5,000 | N/A |
| student1@pilani.bits-pilani.ac.in | STUDENT | 3.92 | ₹2,500 | ✅ Yes |
| student2@pilani.bits-pilani.ac.in | STUDENT | 4.0 | ₹3,200 | ✅ Yes |
| student3@pilani.bits-pilani.ac.in | STUDENT | 4.15 | ₹1,800 | ✅ Yes |
| student4@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹1,500 | ✅ Yes |
| student5@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹2,100 | ✅ Yes |
| student6@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹1,400 | ✅ Yes |
| student7@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹1,900 | ✅ Yes |
| student8@pilani.bits-pilani.ac.in | STUDENT | 0.0 | ₹1,000 | ❌ No (< 3.0) |
| student9@pilani.bits-pilani.ac.in | STUDENT | 0.0 | ₹1,000 | ❌ No (< 3.0) |

## 📊 Demo Data Summary

- **Users:** 10 (1 admin, 9 students)
- **Listings:** 15+ (active and inactive)
- **Ratings:** 20+
- **Trades:** 3 (pending, accepted, rejected)
- **Bids:** 6 (on 2 auctions)
- **Moderation Logs:** 3 (pending, approved, rejected)
- **Reports:** 3 (new, under review, resolved)
- **Chat Messages:** 4
- **Wishlists:** 3
- **Feedbacks:** 3
- **Wallet Transactions:** 6+

## 🎯 Demo Flows Ready

1. ✅ **Marketplace Browsing** - View listings, search, filter
2. ✅ **User Registration & Login** - Register, login, profile
3. ✅ **Create Listing** - Regular, tradeable, biddable
4. ✅ **Regular Purchase** - Buy items with wallet
5. ✅ **Trading** - Create trades, accept/reject
6. ✅ **Bidding** - Place bids, view auctions
7. ✅ **Admin Dashboard** - Reports, users, moderation
8. ✅ **Moderation** - ML-flagged listings, admin review
9. ✅ **Rating & Trust Score** - Rate users, view trust scores
10. ✅ **Wallet & Transactions** - View balance, transactions
11. ✅ **Chat** - Send messages between users
12. ✅ **Wishlist** - Add items to wishlist

## 🔧 Trust Score Calculation

Trust scores are calculated using **Bayesian Average**:

```
Trust Score = (priorMean * priorCount + averageRating * ratingCount) / (priorCount + ratingCount)
```

Where:
- `priorMean = 3.0`
- `priorCount = 5`
- `averageRating` = average of all ratings (1-5)
- `ratingCount` = number of ratings received

**Example:**
- Student1: 8 ratings with average 4.5
- Trust Score = (3.0 * 5 + 4.5 * 8) / (5 + 8) = (15 + 36) / 13 = 3.92

## ⚠️ Important Notes

1. **Trust Scores:** Trust scores are calculated from ratings using Bayesian average. The seed data includes ratings that result in the trust scores shown above.

2. **Images:** Demo listings reference image paths like `/images/listings/macbook-1.jpg`. For a complete demo, you may need to upload actual images or use placeholder images.

3. **ML Moderation:** ML moderation service requires a trained model. If the model doesn't exist, moderation will fail gracefully (listing creation will still work).

4. **Wallet Balances:** Wallet balances are updated when transactions occur. Demo data includes initial balances and some transaction history.

5. **Bidding:** Bidding requires funds to be held in escrow. Previous bids are released when outbid.

6. **Trading:** Trading requires both users to have trust score ≥ 3.0. Demo data includes users with varying trust scores.

## 📝 Next Steps

1. Run the setup script to populate the database
2. Start all services (backend, frontend, ML moderation)
3. Login with demo users and test all flows
4. Customize data as needed for your demo
5. Upload actual images for listings (optional)

## 🐛 Troubleshooting

See `DEMO_GUIDE.md` for detailed troubleshooting steps.

## 📚 Files Created

- `backend/src/main/resources/seed_data.sql` - Comprehensive seed data
- `scripts/setup-demo.sh` - Automated setup script
- `DEMO_GUIDE.md` - Complete demo guide
- `DEMO_SETUP_SUMMARY.md` - This file

---

**Demo is ready! 🚀**

