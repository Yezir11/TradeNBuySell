# Quick Start Guide

## ✅ Database Setup Complete!

The database has been set up with:
- ✅ All tables created (including `moderation_logs`)
- ✅ Seed data inserted (10 users, 15 listings, 3 moderation logs)

## 🚀 Start the Application

### 1. Start Backend (Spring Boot)

```bash
cd backend
mvn spring-boot:run
```

The backend will start on: `http://localhost:8080`

**Note:** The backend should now start successfully since all tables are created.

### 2. Start Frontend (React)

In a **new terminal**:

```bash
cd frontend
npm start
```

The frontend will start on: `http://localhost:3000`

### 3. (Optional) Start ML Moderation Service

In a **new terminal**:

```bash
cd ml-moderation
export MODEL_PATH=../models/best_model.pt  # or model.pt
python api/app.py
```

The ML service will start on: `http://localhost:5000`

**Note:** If the model file doesn't exist, moderation will fail gracefully but the app will still work.

## 🔐 Login Credentials

**All users use password:** `password123`

### Admin
- Email: `admin@pilani.bits-pilani.ac.in`
- Password: `password123`

### Students
- Email: `student1@pilani.bits-pilani.ac.in` (and student2-9)
- Password: `password123`

See `DEMO_CREDENTIALS.md` for full list.

## ✅ Verification

Once backend starts, you should see:
```
Started TradeNBuySellApplication in X.XXX seconds
```

Then you can:
1. Open `http://localhost:3000` in your browser
2. Login with any demo user
3. Browse the marketplace
4. Test all features!

## 🐛 Troubleshooting

### If backend still fails:
1. Check MySQL is running: `mysql -uroot -proot -e "SELECT 1"`
2. Verify tables exist: `mysql -uroot -proot tradenbysell -e "SHOW TABLES;"`
3. Check `moderation_logs` table: `mysql -uroot -proot tradenbysell -e "DESCRIBE moderation_logs;"`

### If frontend proxy errors:
- Make sure backend is running on port 8080
- The proxy errors will disappear once backend starts

---

**You're all set! 🎉**

