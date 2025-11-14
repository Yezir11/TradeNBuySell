# Demo Quick Reference

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

## 👥 Demo Users (Password: `password123`)

| Email | Role | Trust Score | Wallet |
|-------|------|-------------|--------|
| admin@pilani.bits-pilani.ac.in | ADMIN | 5.0 | ₹5,000 |
| student1@pilani.bits-pilani.ac.in | STUDENT | 3.92 | ₹2,500 |
| student2@pilani.bits-pilani.ac.in | STUDENT | 4.0 | ₹3,200 |
| student3@pilani.bits-pilani.ac.in | STUDENT | 4.15 | ₹1,800 |
| student4@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹1,500 |
| student5@pilani.bits-pilani.ac.in | STUDENT | 3.17 | ₹2,100 |

## 🎯 Demo Flows

### 1. Marketplace Browsing
- **URL:** `http://localhost:3000/marketplace`
- View listings, search, filter by category

### 2. Create Listing
- **URL:** `http://localhost:3000/post-listing`
- Login as `student1@pilani.bits-pilani.ac.in`
- Create listing with images
- ML moderation automatically checks

### 3. Trading
- **URL:** `http://localhost:3000/trades`
- Login as `student3@pilani.bits-pilani.ac.in`
- Create trade offer for keyboard (student2)
- Login as `student2@pilani.bits-pilani.ac.in`
- Accept/reject trade

### 4. Bidding
- **URL:** `http://localhost:3000/bids`
- Login as `student1@pilani.bits-pilani.ac.in`
- Browse PS5 auction
- Place bid (must exceed current + increment)

### 5. Admin Dashboard
- **URL:** `http://localhost:3000/admin`
- Login as `admin@pilani.bits-pilani.ac.in`
- View moderation logs
- Review flagged listings
- Take action: APPROVE, REJECT, BLACKLIST

### 6. Wallet & Transactions
- **URL:** `http://localhost:3000/wallet`
- View balance and transaction history

### 7. Chat
- **URL:** `http://localhost:3000/chat`
- Send messages between users

## 📊 Demo Data

- **Users:** 10 (1 admin, 9 students)
- **Listings:** 15+ (regular, tradeable, biddable)
- **Ratings:** 20+
- **Trades:** 3 (pending, accepted, rejected)
- **Bids:** 6 (on 2 auctions)
- **Moderation Logs:** 3 (pending, approved, rejected)
- **Reports:** 3 (new, under review, resolved)

## 🔧 Trust Score Calculation

**Formula:** `(priorMean * priorCount + averageRating * ratingCount) / (priorCount + ratingCount)`

- **priorMean:** 3.0
- **priorCount:** 5
- **averageRating:** Average of all ratings (1-5)
- **ratingCount:** Number of ratings received

**Example:**
- Student1: 8 ratings, avg = 4.5
- Trust Score = (3.0 * 5 + 4.5 * 8) / (5 + 8) = 3.92

## 🐛 Troubleshooting

### Database Connection
```bash
mysql -uroot -proot -e "SELECT 1"
```

### Backend Issues
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Frontend Issues
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm start
```

### ML Moderation Issues
```bash
cd ml-moderation
python api/app.py
curl http://localhost:5000/health
```

## 📝 Important Notes

1. **Trust Scores:** Calculated using Bayesian average from ratings
2. **Trading:** Requires trust score ≥ 3.0
3. **Bidding:** Funds held in escrow while bidding
4. **ML Moderation:** Automatically flags prohibited content
5. **Images:** Demo listings use placeholder image paths

## 🔗 URLs

- **Frontend:** `http://localhost:3000`
- **Backend:** `http://localhost:8080`
- **ML Moderation:** `http://localhost:5000`
- **API Docs:** `http://localhost:8080/swagger-ui.html` (if enabled)

## ✅ Checklist

- [ ] Database setup complete
- [ ] Backend running on port 8080
- [ ] Frontend running on port 3000
- [ ] ML moderation running on port 5000 (optional)
- [ ] All demo users can login
- [ ] Listings visible in marketplace
- [ ] Trades can be created
- [ ] Bids can be placed
- [ ] Admin dashboard accessible
- [ ] Moderation logs visible

---

**Happy Demo! 🚀**

