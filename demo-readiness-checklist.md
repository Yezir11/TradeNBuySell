# TBS (TradeBuySell) - Demo Readiness Checklist

**Project:** BITS Pilani Campus Marketplace  
**Last Updated:** 2024  
**Status:** ⚠️ Work in Progress

---

## 📋 Quick Status Overview

- [ ] **Authentication & User Management** (0/15)
- [ ] **Marketplace & Listings** (0/20)
- [ ] **Listing Management** (0/15)
- [ ] **Bidding System** (0/18)
- [ ] **Trading System** (0/20)
- [ ] **Chat & Messaging** (0/15)
- [ ] **User Profile & Wallet** (0/15)
- [ ] **Admin Dashboard** (0/20)
- [ ] **ML Content Moderation** (0/12)
- [ ] **Featured Listings** (0/12)
- [ ] **Buy Now / Purchase Offers** (0/12)
- [ ] **UI/UX Consistency** (0/20)
- [ ] **Performance & Error Handling** (0/15)
- [ ] **Data & Seeding** (0/15)
- [ ] **Security & Authentication** (0/15)
- [ ] **Demo Flow Testing** (0/20)

**Total Progress:** 0/240 ✅

---

## 1. Authentication & User Management

### Registration & Login
- [ ] User registration with email and password works
- [ ] OAuth2 login (Google) works correctly
- [ ] Login with email/password works
- [ ] Password reset/forgot password functionality
- [ ] Password setup after OAuth login works
- [ ] Logout functionality works correctly
- [ ] Session persistence after page refresh
- [ ] Token expiration handling works

### User State Management
- [ ] User authentication state persists correctly
- [ ] Protected routes redirect to login when unauthenticated
- [ ] User profile data loads correctly on login
- [ ] Admin role detection works correctly
- [ ] Loading states display during authentication

### Demo Credentials
- [ ] Test user accounts created (Rahul Sharma, etc.)
- [ ] Admin account created and accessible
- [ ] Demo credentials documented in README

**Notes:**
- 

---

## 2. Marketplace & Listings

### Listing Display
- [ ] All listings display correctly on marketplace page
- [ ] Listings show images, titles, prices, categories
- [ ] Listings show seller names
- [ ] Featured listings appear at the top with ribbon tag
- [ ] Listing cards are properly formatted and clickable
- [ ] Empty state displays when no listings found
- [ ] Loading state displays while fetching listings

### Search & Filters
- [ ] Search bar works and filters listings dynamically
- [ ] Search shows results as user types (debounced)
- [ ] Category filters work correctly (7 categories)
- [ ] Price range filter works
- [ ] Active filters are visually indicated
- [ ] Clear/reset filters functionality works

### Pagination & Sorting
- [ ] Pagination works correctly
- [ ] Sort by price (low to high, high to low) works
- [ ] Sort by date (newest, oldest) works
- [ ] Pagination info displays correctly

### Listing Categories
- [ ] All 7 categories display correctly
- [ ] Listings are correctly categorized
- [ ] Category navigation highlights active category
- [ ] No misclassified listings (e.g., cycles in Electronics)

**Notes:**
- 

---

## 3. Listing Management

### View Listing Details
- [ ] Listing detail page loads correctly
- [ ] All images display in gallery/carousel
- [ ] Listing title, description, price, category show correctly
- [ ] Seller information displays correctly
- [ ] Listing status (Active, Sold, Inactive) shows correctly
- [ ] "Buy Now" button displays for non-biddable listings
- [ ] "Place Bid" button displays for biddable listings
- [ ] Similar listings section works (if implemented)

### Create Listing (Post Listing)
- [ ] Post listing form loads correctly
- [ ] Title input works (minimum 100 characters enforced)
- [ ] Description input works (minimum 500 characters enforced)
- [ ] Category selection works (all 7 categories available)
- [ ] Price input works correctly
- [ ] Biddable toggle works
- [ ] Image upload works (multiple images)
- [ ] Image preview displays correctly
- [ ] Form validation shows appropriate errors
- [ ] Listing creation successful and redirects correctly
- [ ] New listing appears in marketplace

### Edit/Delete Listing
- [ ] Edit listing functionality works (if implemented)
- [ ] Delete/remove listing works
- [ ] Inactive listings removed from active marketplace

**Notes:**
- 

---

## 4. Bidding System

### Bidding Center
- [ ] Bidding Center page loads correctly
- [ ] Active biddable listings display correctly
- [ ] User's own listings are filtered out from active biddings
- [ ] Listing details show current bid count
- [ ] Bid count displays 0 when no bids exist
- [ ] "My Listings" tab shows user's biddable listings
- [ ] My Listings uses same card layout as My Profile

### Place Bid
- [ ] Place bid form/button works
- [ ] Bid amount input validation works
- [ ] Cannot bid on own listings
- [ ] Cannot bid below current highest bid
- [ ] Bid submission successful
- [ ] Bid appears in listing's bid history immediately
- [ ] User receives confirmation

### View & Manage Bids
- [ ] Listing owner can view all bids on their listings
- [ ] Bid history shows bidder, amount, timestamp
- [ ] Finalize bid functionality works
- [ ] Finalize bid marks listing as sold
- [ ] Winner notification works (if implemented)
- [ ] Unsuccessful bidders notified (if implemented)

**Notes:**
- 

---

## 5. Trading System

### Trade Center
- [ ] Trade Center page loads correctly
- [ ] "New Trade" button works
- [ ] User has approved listing check works before trade creation
- [ ] All tradable listings display in dropdown/selection
- [ ] Multiple listing selection works (checkbox/grid)
- [ ] Selected listings display correctly
- [ ] Cash adjustment input works (positive and negative)
- [ ] Cash adjustment allows paying extra or asking for cash
- [ ] Trade proposal message input works
- [ ] Trade submission successful

### Manage Trades
- [ ] My Trades page shows all user's trades
- [ ] Trade status displays correctly (Pending, Accepted, Rejected, Completed)
- [ ] Trade details show all offered items
- [ ] Trade details show cash adjustment amount and direction
- [ ] Accept trade functionality works
- [ ] Reject trade functionality works
- [ ] Complete trade functionality works
- [ ] Chat with trade partner works from trade page

**Notes:**
- 

---

## 6. Chat & Messaging

### Chat Interface
- [ ] Chat page loads correctly
- [ ] Conversation list displays all conversations
- [ ] Active conversations highlight correctly
- [ ] Chat messages display correctly (sent and received)
- [ ] Message timestamps display correctly
- [ ] Send message functionality works
- [ ] Real-time message updates work (if WebSocket implemented)

### Listing Context in Chat
- [ ] Listing context displays in chat when conversation is about a listing
- [ ] Listing image, title, price show in chat context banner
- [ ] Listing context clickable to view listing details
- [ ] Context persists across page refreshes

### Chat from Various Sources
- [ ] Chat from marketplace listing works
- [ ] Chat from trade proposal works
- [ ] Chat from bid notification works
- [ ] Chat from purchase offer works
- [ ] New conversation creates when needed

**Notes:**
- 

---

## 7. User Profile & Wallet

### My Profile
- [ ] Profile page loads with user information
- [ ] User details display correctly (name, email, trust score)
- [ ] Profile picture displays (if implemented)
- [ ] Trust score calculation displays correctly
- [ ] Ratings display correctly (if implemented)
- [ ] Edit profile functionality works

### My Listings
- [ ] My Listings section displays correctly
- [ ] All tabs work: All, Active, Inactive, Moderated Ads
- [ ] Listing count shows correctly for each tab
- [ ] Search functionality works in My Listings
- [ ] Filter functionality works
- [ ] Listing cards display properly with images and details
- [ ] Cards are clickable and navigate to listing details
- [ ] Remove listing works for inactive ads
- [ ] Moderated Ads tab only shows flagged listings
- [ ] No non-flagged listings in Moderated Ads tab

### Wallet
- [ ] Wallet page loads with balance
- [ ] Wallet balance displays correctly
- [ ] Transaction history displays correctly
- [ ] Transaction types categorized correctly
- [ ] Add funds functionality works (if implemented)
- [ ] Withdraw funds functionality works (if implemented)

**Notes:**
- 

---

## 8. Admin Dashboard

### Admin Access
- [ ] Admin dashboard accessible only to admin users
- [ ] Admin role detection works correctly
- [ ] Non-admin users cannot access admin routes

### Moderation
- [ ] Flagged listings display correctly
- [ ] Flagged listing images display correctly
- [ ] User details show with flagged listings
- [ ] Chat with user functionality works from admin dashboard
- [ ] Listing context displays in admin chat
- [ ] Approve/reject listing functionality works
- [ ] Moderation reasons/logs recorded correctly

### Statistics & Reports
- [ ] Dashboard statistics display correctly
- [ ] User count, listing count, trade count accurate
- [ ] Recent activities display correctly
- [ ] Reports/analytics show correctly (if implemented)

### System Settings
- [ ] App settings can be modified
- [ ] Mandatory moderation toggle works
- [ ] Setting changes persist correctly

**Notes:**
- 

---

## 9. ML Content Moderation

### ML API Integration
- [ ] Flask ML API server starts correctly
- [ ] ML API responds to health checks
- [ ] Model loads correctly (Vision Transformer)
- [ ] Image classification works
- [ ] Text classification works (DistilBERT)
- [ ] Combined multimodal classification works

### Moderation Flow
- [ ] New listings automatically checked for prohibited content
- [ ] Prohibited images flagged correctly
- [ ] Prohibited text flagged correctly
- [ ] Flagged listings hidden from marketplace
- [ ] User notification shows when listing is flagged
- [ ] Flagged listings appear in admin dashboard
- [ ] Moderation logs created correctly

### Moderation Dashboard
- [ ] ML Content Moderation tab accessible in admin dashboard
- [ ] Moderation statistics display correctly
- [ ] Recent moderation actions show correctly

**Notes:**
- ML API port: 5000
- Backend integration: `/api/moderation/check`

---

## 10. Featured Listings

### Featured Packages
- [ ] Featured packages display correctly
- [ ] Package pricing and duration display correctly
- [ ] Package selection works
- [ ] Payment through wallet works
- [ ] Featured listing activated after payment

### Featured Listing Display
- [ ] Featured listings appear at top of marketplace
- [ ] Featured ribbon/tag displays correctly on listings
- [ ] Featured listings sorted by featured date
- [ ] Featured expiration works correctly
- [ ] Featured listings revert to normal after expiration

### "Sell Faster Now" Button
- [ ] Button displays on user's listings
- [ ] Clicking button opens featured packages selection
- [ ] Payment flow works correctly
- [ ] Confirmation message displays

**Notes:**
- 

---

## 11. Buy Now / Purchase Offers

### Buy Now Workflow
- [ ] "Buy Now" button displays on non-biddable listings
- [ ] Clicking "Buy Now" opens listing detail page
- [ ] Buy Now button visible on listing detail page
- [ ] Purchase offer form appears when clicking Buy Now
- [ ] Offer amount input works
- [ ] Message to seller input works
- [ ] Purchase offer submission works

### Purchase Offer Management
- [ ] Seller receives purchase offer notification
- [ ] Purchase offer appears in seller's chat
- [ ] Listing context shows in purchase offer chat
- [ ] Seller can accept offer
- [ ] Seller can reject offer
- [ ] Seller can counter-offer (if implemented)
- [ ] Buyer receives notification of seller's response

**Notes:**
- 

---

## 12. UI/UX Consistency

### Theme & Colors
- [ ] Dark theme applied consistently across all pages
- [ ] BITS Pilani colors used correctly (Blue, Red, Yellow, Gold, Sky Blue)
- [ ] Navbar logo displays correctly in all locations
- [ ] Logo size appropriate for navbar
- [ ] Color contrast meets accessibility standards
- [ ] Text readable on all background colors

### Navigation
- [ ] Navigation bar displays correctly on all pages
- [ ] Active route highlights correctly (red underline)
- [ ] Navigation links work correctly
- [ ] Mobile menu works correctly
- [ ] Search bar in header works on all pages
- [ ] User dropdown menu works correctly

### Responsive Design
- [ ] Desktop layout works correctly (>1024px)
- [ ] Tablet layout works correctly (768px - 1024px)
- [ ] Mobile layout works correctly (<768px)
- [ ] Images scale correctly on all screen sizes
- [ ] Forms are usable on mobile devices
- [ ] Touch targets are appropriately sized

### Loading & Error States
- [ ] Loading spinners display during data fetch
- [ ] Error messages display clearly
- [ ] Empty states have helpful messages
- [ ] 404 page exists and works
- [ ] Network error handling works

**Notes:**
- 

---

## 13. Performance & Error Handling

### Page Load Performance
- [ ] Marketplace page loads in < 2 seconds
- [ ] Listing detail page loads in < 1 second
- [ ] Images lazy load correctly
- [ ] No console errors on page load
- [ ] API calls optimized (no unnecessary requests)

### Error Handling
- [ ] Network errors handled gracefully
- [ ] API errors display user-friendly messages
- [ ] Form validation errors show clearly
- [ ] 404 errors handled correctly
- [ ] 500 errors handled gracefully
- [ ] Error boundaries implemented (if React error boundaries used)

### Data Validation
- [ ] Input validation works on frontend
- [ ] Input validation works on backend
- [ ] SQL injection protection in place
- [ ] XSS protection in place
- [ ] File upload validation works

**Notes:**
- 

---

## 14. Data & Seeding

### Database Setup
- [ ] Database schema up to date
- [ ] All migrations applied correctly
- [ ] Seed data loads correctly
- [ ] Demo users created with correct credentials
- [ ] Demo listings created (200+ listings)
- [ ] Demo categories populated correctly

### Data Quality
- [ ] All listings have images
- [ ] All listings have proper titles (100+ characters)
- [ ] All listings have proper descriptions (500+ characters)
- [ ] All listings categorized correctly
- [ ] No duplicate listings
- [ ] No orphaned data (images without listings, etc.)

### Demo Scenarios
- [ ] Sample trades created for demo
- [ ] Sample bids created for demo
- [ ] Sample chats created for demo
- [ ] Featured listings examples created
- [ ] Flagged listings examples created (for moderation demo)

**Notes:**
- Seed file: `demo_tradenbuyseed_v4.sql`
- Demo user: Rahul Sharma

---

## 15. Security & Authentication

### Authentication Security
- [ ] JWT tokens expire correctly
- [ ] Tokens refresh correctly
- [ ] Tokens invalidated on logout
- [ ] Password hashing uses secure algorithm (BCrypt)
- [ ] OAuth2 state parameter validated

### Authorization
- [ ] Users can only edit their own listings
- [ ] Users can only access their own profile
- [ ] Users can only view their own trades
- [ ] Admin routes protected correctly
- [ ] API endpoints validate user permissions

### Data Security
- [ ] Sensitive data not exposed in API responses
- [ ] File uploads restricted to allowed types
- [ ] File size limits enforced
- [ ] SQL injection protection verified
- [ ] XSS protection verified

**Notes:**
- 

---

## 16. Demo Flow Testing

### Complete User Journey 1: Browse & Purchase
1. [ ] User lands on homepage
2. [ ] User browses marketplace
3. [ ] User searches for specific item
4. [ ] User filters by category
5. [ ] User views listing details
6. [ ] User clicks "Buy Now"
7. [ ] User submits purchase offer
8. [ ] Seller receives notification
9. [ ] Seller accepts offer in chat
10. [ ] Transaction completes

### Complete User Journey 2: Bidding Flow
1. [ ] User browses Bidding Center
2. [ ] User views biddable listing
3. [ ] User places bid
4. [ ] Listing owner sees bid in "My Listings"
5. [ ] Listing owner views all bids
6. [ ] Listing owner finalizes highest bid
7. [ ] Listing marked as sold
8. [ ] Winner and other bidders notified

### Complete User Journey 3: Trade Flow
1. [ ] User posts listing
2. [ ] User browses tradable listings
3. [ ] User selects multiple listings for trade
4. [ ] User proposes trade with cash adjustment
5. [ ] Recipient receives trade proposal
6. [ ] Recipient views trade details
7. [ ] Recipient accepts trade
8. [ ] Both users complete trade
9. [ ] Trust scores updated

### Complete User Journey 4: Admin Moderation
1. [ ] Admin logs in
2. [ ] Admin views flagged listings
3. [ ] Admin reviews listing details
4. [ ] Admin chats with listing owner
5. [ ] Admin approves/rejects listing
6. [ ] Listing status updates correctly
7. [ ] User notified of decision

### Complete User Journey 5: Featured Listing
1. [ ] User views their listings
2. [ ] User clicks "Sell Faster Now"
3. [ ] User selects featured package
4. [ ] User pays from wallet
5. [ ] Listing becomes featured
6. [ ] Featured listing appears at top of marketplace
7. [ ] Featured tag displays correctly

**Notes:**
- 

---

## 📝 Demo Preparation Checklist

### Pre-Demo Setup
- [ ] All services running (Backend, Frontend, ML API, MySQL)
- [ ] Database seeded with demo data
- [ ] Demo user accounts ready
- [ ] Browser cache cleared
- [ ] Test all demo flows once before presentation

### Demo Environment
- [ ] Stable internet connection
- [ ] Browser developer tools ready (for debugging if needed)
- [ ] Demo credentials prepared (not visible to audience)
- [ ] Backup demo data ready (in case of issues)

### Presentation Materials
- [ ] Architecture diagram prepared (if needed)
- [ ] Feature list prepared
- [ ] Key talking points prepared
- [ ] Known issues/limitations documented

---

## 🐛 Known Issues & Limitations

### Critical Issues
- 

### Medium Priority Issues
- 

### Minor Issues
- 

### Future Enhancements
- 

---

## 📊 Progress Tracking

**Last Updated:** [Date]  
**Overall Completion:** 0%  
**Critical Items Remaining:** 0  
**Medium Priority Remaining:** 0  
**Ready for Demo:** ❌ No

---

## ✅ Sign-Off

- [ ] **Technical Lead:** _________________ Date: __________
- [ ] **Project Manager:** _________________ Date: __________
- [ ] **Demo Presenter:** _________________ Date: __________

**Final Approval for Demo:** ❌ Not Approved

---

## 📞 Support & Resources

**Documentation:**
- README.md
- API Documentation (if available)
- Database Schema Documentation

**Key Files:**
- Seed Data: `demo_tradenbuyseed_v4.sql`
- Environment Config: `.env` files
- ML API: `ml-moderation/` directory

**Quick Start Commands:**
```bash
# Backend
cd backend && ./mvnw spring-boot:run

# Frontend
cd frontend && npm start

# ML API
cd ml-moderation && python app.py
```

---

**Note:** Check off items as you verify them. Update the progress percentages as you complete sections. Add notes to any items that need attention or have issues.

