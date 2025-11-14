# TradeNBuySell Demo Guide

Complete guide for running and demonstrating the TradeNBuySell application.

## 📋 Prerequisites

1. **MySQL Database** running on localhost:3306
   - Username: `root`
   - Password: `root`
   - Database: `tradenbysell` (will be created automatically)

2. **Java 17+** installed

3. **Node.js 16+** and npm installed

4. **Python 3.10+** installed (for ML moderation service)

5. **Maven** installed (for backend)

## 🚀 Quick Setup

### 1. Setup Database with Seed Data

```bash
# Navigate to project root
cd /path/to/SEMProject

# Run the setup script
./scripts/setup-demo.sh
```

Or manually:

```bash
# Create database and schema
mysql -uroot -proot < backend/src/main/resources/schema.sql
mysql -uroot -proot < backend/src/main/resources/moderation_schema.sql

# Insert seed data
mysql -uroot -proot tradenbysell < backend/src/main/resources/seed_data.sql
```

### 2. Start Backend (Spring Boot)

```bash
cd backend
mvn spring-boot:run
```

Backend runs on: `http://localhost:8080`

### 3. Start Frontend (React)

```bash
cd frontend
npm install  # First time only
npm start
```

Frontend runs on: `http://localhost:3000`

### 4. Start ML Moderation Service (Flask)

```bash
cd ml-moderation
pip install -r requirements.txt  # First time only
export MODEL_PATH=../models/best_model.pt  # or model.pt
python api/app.py
```

ML service runs on: `http://localhost:5000`

## 👥 Demo User Credentials

**All users use password: `password123`**

### Admin User
- **Email:** `admin@pilani.bits-pilani.ac.in`
- **Password:** `password123`
- **Role:** ADMIN
- **Wallet Balance:** ₹5,000.00
- **Trust Score:** 5.0

### Student Users (High Trust Score - Can Trade)

#### Student 1 - Rahul Sharma
- **Email:** `student1@pilani.bits-pilani.ac.in`
- **Password:** `password123`
- **Wallet Balance:** ₹2,500.00
- **Trust Score:** ~4.2 (from ratings)
- **Listings:** MacBook Pro, Gaming Mouse

#### Student 2 - Priya Patel
- **Email:** `student2@pilani.bits-pilani.ac.in`
- **Password:** `password123`
- **Wallet Balance:** ₹3,200.00
- **Trust Score:** ~4.5 (from ratings)
- **Listings:** Sony Headphones, Mechanical Keyboard

#### Student 3 - Arjun Kumar
- **Email:** `student3@pilani.bits-pilani.ac.in`
- **Password:** `password123`
- **Wallet Balance:** ₹1,800.00
- **Trust Score:** ~4.8 (from ratings)
- **Listings:** iPad Air, Guitar

#### Student 4 - Ananya Singh
- **Email:** `student4@pilani.bits-pilani.ac.in`
- **Password:** `password123`
- **Wallet Balance:** ₹1,500.00
- **Trust Score:** ~4.0 (from ratings)
- **Listings:** Office Chair, Bicycle

### Student Users (Medium/Low Trust Score)

- **Student 5:** `student5@pilani.bits-pilani.ac.in` - Trust Score: 3.8
- **Student 6:** `student6@pilani.bits-pilani.ac.in` - Trust Score: 3.5
- **Student 7:** `student7@pilani.bits-pilani.ac.in` - Trust Score: 4.3
- **Student 8:** `student8@pilani.bits-pilani.ac.in` - Trust Score: 2.5 (cannot trade - below 3.0)
- **Student 9:** `student9@pilani.bits-pilani.ac.in` - Trust Score: 0.0 (new user)

## 🎯 Demo Flow

### 1. Marketplace Browsing (Public)
- **URL:** `http://localhost:3000/marketplace`
- View all active listings
- Browse by category (Electronics, Furniture, Books, etc.)
- Search for items
- View listing details (no login required)

### 2. User Registration & Login
- **URL:** `http://localhost:3000/auth`
- Register a new user (must use `@pilani.bits-pilani.ac.in` email)
- Login with demo credentials
- View user profile with wallet balance and trust score

### 3. Create Listing
- **URL:** `http://localhost:3000/post-listing`
- Login as `student1@pilani.bits-pilani.ac.in`
- Create a new listing:
  - Title, description, price
  - Category, tags
  - Upload images
  - Set as regular purchase, tradeable, or biddable
- ML moderation automatically checks the listing
- If flagged, listing is deactivated and sent to admin review

### 4. Regular Purchase Flow
- Browse marketplace
- Click on a listing (e.g., MacBook Pro)
- View listing details, images, seller info, trust score
- Chat with seller (if logged in)
- Purchase item (wallet balance checked)

### 5. Trading Flow
- **Requirements:** Both users need trust score ≥ 3.0
- Login as `student3@pilani.bits-pilani.ac.in`
- Go to Trade Center
- Find tradeable listing (e.g., Mechanical Keyboard by student2)
- Create trade offer:
  - Select items to offer (e.g., Guitar)
  - Add optional cash adjustment (e.g., ₹500)
  - Submit trade request
- Login as `student2@pilani.bits-pilani.ac.in`
- View pending trade in Trade Center
- Accept or reject trade
- On accept: both listings deactivated, wallet transfers occur

### 6. Bidding Flow
- **URL:** `http://localhost:3000/bids`
- Login as `student1@pilani.bits-pilani.ac.in`
- Browse biddable listings (e.g., PS5, Drone)
- View auction details:
  - Starting price
  - Current highest bid
  - Bid increment
  - Time remaining
- Place a bid (must exceed current highest + increment)
- Funds held in escrow while bidding
- Previous bidder's funds released when outbid
- At auction end: highest bid wins, funds transfer

### 7. Admin Dashboard
- **URL:** `http://localhost:3000/admin`
- Login as `admin@pilani.bits-pilani.ac.in`
- View three tabs:
  - **Reports:** User-reported issues
  - **Users:** User management (suspend/activate)
  - **Moderation:** ML-flagged listings
    - View ML predictions (label, confidence)
    - View image heatmaps (Grad-CAM)
    - View text explanations (SHAP)
    - Take action: APPROVE, REJECT, BLACKLIST

### 8. Moderation Flow
- Create a listing with potentially prohibited content
- ML moderation automatically flags it
- Listing is deactivated
- Admin reviews in moderation tab
- Admin sees:
  - Predicted label (weapon, alcohol, drugs)
  - Confidence score
  - Image heatmap (highlighted regions)
  - Text explanation (important tokens)
- Admin takes action:
  - **APPROVE:** Listing activated
  - **REJECT:** Listing remains inactive
  - **BLACKLIST:** Listing inactive + user suspended

### 9. Rating & Trust Score
- After a transaction, rate the other user
- Rating: 1-5 stars with optional comment
- Trust score calculated using Bayesian average:
  - Formula: `(priorMean * priorCount + averageRating * ratingCount) / (priorCount + ratingCount)`
  - Prior mean: 3.0, Prior count: 5
- Trust score displayed on user profile and listings
- Trading requires trust score ≥ 3.0

### 10. Wallet & Transactions
- **URL:** `http://localhost:3000/wallet`
- View wallet balance (starts at ₹1,000.00)
- View transaction history:
  - Purchases (debits)
  - Sales (credits)
  - Bids (escrow holds/releases)
  - Trades (cash adjustments)
  - Refunds

### 11. Chat
- **URL:** `http://localhost:3000/chat`
- Send messages to other users
- Messages linked to listings
- Report inappropriate messages

### 12. Wishlist
- Add listings to wishlist
- View wishlist in profile
- Get notified about price changes (if implemented)

## 📊 Demo Data Overview

### Users
- 1 Admin user
- 9 Student users with varying trust scores

### Listings
- 15+ listings (active and inactive)
- Regular purchase listings
- Tradeable listings
- Biddable listings (auctions)
- Flagged listings (for moderation demo)

### Ratings
- 20+ ratings to establish trust scores
- Ratings linked to listings and users

### Trades
- 1 Pending trade (for demo)
- 1 Accepted trade (historical)
- 1 Rejected trade (historical)

### Bids
- Multiple bids on PS5 auction
- Multiple bids on Drone auction
- Winning bids highlighted

### Moderation Logs
- 3 moderation logs:
  - 1 Pending (flagged listing)
  - 1 Approved (safe listing)
  - 1 Rejected (prohibited content)

### Reports
- 3 reports:
  - 1 New (listing report)
  - 1 Under Review (user report)
  - 1 Resolved (message report)

## 🔧 Troubleshooting

### Database Connection Issues
```bash
# Check MySQL is running
mysql -uroot -proot -e "SELECT 1"

# Create database manually
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS tradenbysell"
```

### Backend Issues
```bash
# Check if port 8080 is available
lsof -i :8080

# Clear Maven cache
cd backend
mvn clean install
```

### Frontend Issues
```bash
# Clear node_modules and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### ML Moderation Service Issues
```bash
# Check if model exists
ls -la ml-moderation/models/

# Test ML service
curl http://localhost:5000/health
```

### Trust Score Not Updating
- Trust scores are calculated when ratings are added
- If manually inserted, trust scores may not match Bayesian average
- Use the application's rating feature to update trust scores

## 📝 Notes

1. **Trust Scores:** Trust scores are calculated using Bayesian average in the application. If you manually insert ratings, trust scores may not update automatically. Use the application's rating feature to update trust scores.

2. **Images:** Demo listings reference image paths like `/images/listings/macbook-1.jpg`. For a complete demo, you may need to upload actual images or use placeholder images.

3. **ML Moderation:** ML moderation service requires a trained model. If the model doesn't exist, moderation will fail gracefully (listing creation will still work).

4. **Wallet Balances:** Wallet balances are updated when transactions occur. Demo data includes initial balances and some transaction history.

5. **Bidding:** Bidding requires funds to be held in escrow. Previous bids are released when outbid.

6. **Trading:** Trading requires both users to have trust score ≥ 3.0. Demo data includes users with varying trust scores.

## 🎬 Demo Script

1. **Start all services** (backend, frontend, ML moderation)
2. **Login as admin** - Show admin dashboard, moderation tab
3. **Login as student1** - Create listing, view marketplace
4. **Login as student2** - Browse listings, create trade offer
5. **Login as student3** - Accept trade, view bids
6. **Login as admin** - Review moderation logs, approve/reject
7. **Show trust scores** - Explain Bayesian average calculation
8. **Show wallet** - View transactions, escrow holds
9. **Show chat** - Send messages between users
10. **Show ratings** - Rate users after transactions

## 📚 Additional Resources

- **API Documentation:** `http://localhost:8080/swagger-ui.html` (if Swagger is enabled)
- **ML Moderation API:** `http://localhost:5000/health`
- **Database Schema:** `backend/src/main/resources/schema.sql`
- **Moderation Schema:** `backend/src/main/resources/moderation_schema.sql`
- **Seed Data:** `backend/src/main/resources/seed_data.sql`

## ✅ Checklist

- [ ] MySQL database running
- [ ] Database schema created
- [ ] Seed data inserted
- [ ] Backend running on port 8080
- [ ] Frontend running on port 3000
- [ ] ML moderation service running on port 5000
- [ ] All demo users can login
- [ ] Listings visible in marketplace
- [ ] Trades can be created and accepted
- [ ] Bids can be placed
- [ ] Admin dashboard accessible
- [ ] Moderation logs visible
- [ ] Trust scores calculated correctly
- [ ] Wallet transactions working

---

**Happy Demo! 🚀**

