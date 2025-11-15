# TBS - Minimal Testing Action Plan

**Goal:** Establish essential test coverage for critical functionality  
**Approach:** Focus on high-impact, minimal-effort tests  
**Estimated Time:** 8-12 hours for complete setup

---

## 📋 Testing Strategy Overview

### Test Pyramid
```
     /\
    /  \  E2E Tests (2-3 critical flows)
   /____\  
  /      \  Integration Tests (API endpoints, key services)
 /________\
/          \ Unit Tests (Business logic, utilities)
```

### Priority Levels
- **P0 (Critical):** Must test - Core business logic, security, payments
- **P1 (High):** Should test - User flows, API endpoints
- **P2 (Nice-to-have):** Optional - UI components, edge cases

---

## 🎯 Phase 1: Backend Unit Tests (Priority: P0)

### Setup
```bash
cd backend
# Verify JUnit 5 and Mockito in pom.xml
```

### Tests to Write (6-8 hours)

#### 1. Service Layer Tests

**AuthServiceTest**
- [ ] `registerUser()` - Success case
- [ ] `registerUser()` - Duplicate email
- [ ] `login()` - Valid credentials
- [ ] `login()` - Invalid credentials
- [ ] `validateToken()` - Valid token
- [ ] `validateToken()` - Expired token

**ListingServiceTest**
- [ ] `createListing()` - Success case
- [ ] `createListing()` - Missing required fields
- [ ] `getListings()` - Pagination works
- [ ] `getListings()` - Filter by category
- [ ] `updateListingStatus()` - Status update works

**BidServiceTest**
- [ ] `placeBid()` - Valid bid
- [ ] `placeBid()` - Bid lower than current highest
- [ ] `placeBid()` - Cannot bid on own listing
- [ ] `finalizeBid()` - Success case

**TradeServiceTest**
- [ ] `createTrade()` - Success case
- [ ] `createTrade()` - User has no approved listing
- [ ] `acceptTrade()` - Success case
- [ ] `acceptTrade()` - Invalid trade state

**WalletServiceTest**
- [ ] `addFunds()` - Success case
- [ ] `deductFunds()` - Success case
- [ ] `deductFunds()` - Insufficient funds exception
- [ ] `getBalance()` - Returns correct balance

**ModerationServiceTest**
- [ ] `checkListing()` - Flags prohibited content
- [ ] `checkListing()` - Allows safe content
- [ ] `createModerationLog()` - Logs created correctly

**File:** `backend/src/test/java/com/tradenbysell/service/*ServiceTest.java`

**Example Template:**
```java
@ExtendWith(MockitoExtension.class)
class ListingServiceTest {
    @Mock
    private ListingRepository listingRepository;
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private ListingService listingService;
    
    @Test
    void createListing_Success() {
        // Given
        User user = new User();
        user.setId(1L);
        ListingCreateDTO dto = new ListingCreateDTO();
        // ... setup
        
        // When
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(listingRepository.save(any(Listing.class))).thenAnswer(invocation -> invocation.getArgument(0));
        
        ListingDTO result = listingService.createListing(1L, dto);
        
        // Then
        assertNotNull(result);
        assertEquals(dto.getTitle(), result.getTitle());
        verify(listingRepository).save(any(Listing.class));
    }
}
```

---

## 🔗 Phase 2: Backend Integration Tests (Priority: P0-P1)

### Setup
```bash
# Add to pom.xml if not present:
# - spring-boot-starter-test
# - Testcontainers or H2 in-memory database
```

### Tests to Write (4-6 hours)

#### 1. API Controller Tests

**AuthControllerIT**
- [ ] `POST /api/auth/register` - Success (201)
- [ ] `POST /api/auth/register` - Duplicate email (400)
- [ ] `POST /api/auth/login` - Success (200)
- [ ] `POST /api/auth/login` - Invalid credentials (401)
- [ ] `GET /api/auth/validate` - Valid token (200)
- [ ] `GET /api/auth/validate` - Invalid token (401)

**ListingControllerIT**
- [ ] `GET /api/listings` - Returns paginated list (200)
- [ ] `GET /api/listings?category=Electronics` - Filters correctly (200)
- [ ] `GET /api/listings/:id` - Returns listing (200)
- [ ] `GET /api/listings/:id` - Not found (404)
- [ ] `POST /api/listings` - Creates listing (201)
- [ ] `POST /api/listings` - Unauthorized (401)
- [ ] `PUT /api/listings/:id` - Updates listing (200)
- [ ] `DELETE /api/listings/:id` - Deletes listing (204)

**BidControllerIT**
- [ ] `POST /api/bids` - Creates bid (201)
- [ ] `POST /api/bids` - Invalid bid amount (400)
- [ ] `GET /api/bids/listing/:id` - Returns bids (200)
- [ ] `PUT /api/bids/:id/finalize` - Finalizes bid (200)

**TradeControllerIT**
- [ ] `POST /api/trades` - Creates trade (201)
- [ ] `GET /api/trades` - Returns user trades (200)
- [ ] `PUT /api/trades/:id/accept` - Accepts trade (200)

**WalletControllerIT**
- [ ] `GET /api/wallet/balance` - Returns balance (200)
- [ ] `POST /api/wallet/transactions` - Returns history (200)

**File:** `backend/src/test/java/com/tradenbysell/controller/*ControllerIT.java`

**Example Template:**
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@Transactional
class ListingControllerIT {
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ListingRepository listingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Test
    void getListings_ReturnsPaginatedList() throws Exception {
        // Given - Create test data
        User user = createTestUser();
        createTestListing(user);
        
        // When & Then
        mockMvc.perform(get("/api/listings")
                .param("page", "0")
                .param("size", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").isArray())
            .andExpect(jsonPath("$.totalElements").value(greaterThan(0)));
    }
    
    @Test
    void createListing_Unauthorized_Returns401() throws Exception {
        ListingCreateDTO dto = new ListingCreateDTO();
        // ... setup dto
        
        mockMvc.perform(post("/api/listings")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(dto)))
            .andExpect(status().isUnauthorized());
    }
}
```

#### 2. Database Integration Tests

**RepositoryTests**
- [ ] `ListingRepository.findByCategory()` - Works correctly
- [ ] `ListingRepository.findBySeller()` - Returns user listings
- [ ] `BidRepository.findByListing()` - Returns listing bids
- [ ] `TradeRepository.findByInitiatorOrRecipient()` - Returns user trades

**File:** `backend/src/test/java/com/tradenbysell/repository/*RepositoryTest.java`

---

## ⚛️ Phase 3: Frontend Unit Tests (Priority: P1)

### Setup
```bash
cd frontend
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom
```

Add to `package.json`:
```json
{
  "scripts": {
    "test": "react-scripts test --watchAll=false",
    "test:coverage": "react-scripts test --coverage --watchAll=false"
  },
  "jest": {
    "testEnvironment": "jsdom"
  }
}
```

### Tests to Write (3-4 hours)

#### 1. Component Tests

**AuthContextTest**
- [ ] `login()` - Sets user state correctly
- [ ] `logout()` - Clears user state
- [ ] `isAuthenticated()` - Returns correct value

**ListingServiceTest (if using service layer)**
- [ ] `fetchListings()` - Returns listings
- [ ] `createListing()` - Creates listing
- [ ] `searchListings()` - Filters correctly

**Utility Tests**
- [ ] `formatPrice()` - Formats correctly
- [ ] `formatDate()` - Formats correctly
- [ ] `validateEmail()` - Validates correctly

**File:** `frontend/src/**/*.test.js` or `*.test.jsx`

**Example Template:**
```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import { AuthProvider, useAuth } from '../context/AuthContext';

describe('AuthContext', () => {
  it('login sets user state correctly', async () => {
    const TestComponent = () => {
      const { login, user } = useAuth();
      
      return (
        <div>
          <button onClick={() => login({ email: 'test@example.com' })}>
            Login
          </button>
          {user && <div data-testid="user">{user.email}</div>}
        </div>
      );
    };
    
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );
    
    fireEvent.click(screen.getByText('Login'));
    expect(screen.getByTestId('user')).toHaveTextContent('test@example.com');
  });
});
```

---

## 🔄 Phase 4: Integration Tests - API + Frontend (Priority: P0)

### Setup
- Use Cypress or Playwright (recommended: Playwright for simplicity)
- Or use React Testing Library with MSW (Mock Service Worker)

### Tests to Write (4-6 hours)

#### Option A: Using Playwright (Recommended)

**Setup:**
```bash
cd frontend
npm install --save-dev @playwright/test
npx playwright install
```

**Critical User Flows:**

**1. Authentication Flow**
- [ ] User can register
- [ ] User can login
- [ ] User can logout
- [ ] Protected routes redirect to login

**File:** `frontend/e2e/auth.spec.js`
```javascript
const { test, expect } = require('@playwright/test');

test('user can login', async ({ page }) => {
  await page.goto('http://localhost:3000/auth');
  await page.fill('input[type="email"]', 'test@example.com');
  await page.fill('input[type="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL('http://localhost:3000/marketplace');
  await expect(page.locator('text=Marketplace')).toBeVisible();
});
```

**2. Marketplace Flow**
- [ ] User can view listings
- [ ] User can search listings
- [ ] User can filter by category
- [ ] User can view listing details

**3. Purchase Flow**
- [ ] User can click "Buy Now"
- [ ] User can submit purchase offer
- [ ] Offer appears in seller's chat

**4. Bidding Flow**
- [ ] User can place bid
- [ ] Bid appears in listing
- [ ] Listing owner can finalize bid

**5. Trading Flow**
- [ ] User can create trade
- [ ] Trade appears for recipient
- [ ] Recipient can accept trade

**File:** `frontend/e2e/*.spec.js`

---

## 📊 Test Coverage Goals

### Minimum Coverage Targets
- **Backend Services:** 60-70% (focus on business logic)
- **Backend Controllers:** 50-60% (critical endpoints)
- **Frontend Components:** 40-50% (critical flows only)
- **E2E Tests:** 3-5 critical user journeys

### Files to Focus On
1. `AuthService.java` - Authentication logic
2. `ListingService.java` - Listing management
3. `BidService.java` - Bidding logic
4. `TradeService.java` - Trading logic
5. `WalletService.java` - Payment logic
6. `ModerationService.java` - Content moderation

---

## 🚀 Quick Start Guide

### Step 1: Backend Unit Tests (2 hours)
```bash
cd backend
# Create test directory structure
mkdir -p src/test/java/com/tradenbysell/service
mkdir -p src/test/java/com/tradenbysell/controller
mkdir -p src/test/java/com/tradenbysell/repository

# Write AuthServiceTest first (highest priority)
# Run: ./mvnw test
```

### Step 2: Backend Integration Tests (2 hours)
```bash
# Write AuthControllerIT
# Write ListingControllerIT
# Run: ./mvnw test
```

### Step 3: Frontend Unit Tests (1 hour)
```bash
cd frontend
# Write AuthContext test
# Run: npm test
```

### Step 4: E2E Tests (2-3 hours)
```bash
cd frontend
# Install Playwright
# Write auth flow test
# Write marketplace flow test
# Run: npx playwright test
```

---

## 📝 Test Execution Commands

### Backend
```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=AuthServiceTest

# Run with coverage
./mvnw test jacoco:report
```

### Frontend
```bash
# Run unit tests
npm test

# Run with coverage
npm run test:coverage

# Run E2E tests (Playwright)
npx playwright test

# Run E2E in headed mode
npx playwright test --headed
```

---

## ✅ Testing Checklist

### Backend Tests
- [ ] AuthServiceTest written and passing
- [ ] ListingServiceTest written and passing
- [ ] BidServiceTest written and passing
- [ ] TradeServiceTest written and passing
- [ ] WalletServiceTest written and passing
- [ ] AuthControllerIT written and passing
- [ ] ListingControllerIT written and passing
- [ ] BidControllerIT written and passing
- [ ] All tests passing in CI/CD pipeline

### Frontend Tests
- [ ] AuthContext test written and passing
- [ ] Critical utility functions tested
- [ ] E2E authentication flow tested
- [ ] E2E marketplace flow tested
- [ ] E2E purchase flow tested
- [ ] All tests passing

---

## 🎯 Testing Priorities Summary

### Must Test (P0) - Do First
1. ✅ Authentication (login, register, token validation)
2. ✅ Listing creation and retrieval
3. ✅ Bid placement and validation
4. ✅ Trade creation and acceptance
5. ✅ Wallet balance and transactions
6. ✅ Content moderation flagging

### Should Test (P1) - Do Second
1. ✅ Search and filter functionality
2. ✅ Listing updates and deletion
3. ✅ Chat message creation
4. ✅ Purchase offer workflow
5. ✅ Featured listing payment

### Nice to Have (P2) - Do If Time
1. ⚪ UI component rendering
2. ⚪ Edge cases and error handling
3. ⚪ Performance testing
4. ⚪ Load testing

---

## 🔧 Test Data Setup

### Create Test Utilities

**Backend:**
```java
// src/test/java/com/tradenbysell/util/TestDataBuilder.java
public class TestDataBuilder {
    public static User createTestUser() {
        User user = new User();
        user.setEmail("test@example.com");
        user.setFullName("Test User");
        // ... set other fields
        return user;
    }
    
    public static Listing createTestListing(User seller) {
        Listing listing = new Listing();
        listing.setTitle("Test Listing");
        listing.setSeller(seller);
        // ... set other fields
        return listing;
    }
}
```

**Frontend:**
```javascript
// src/test/utils/testHelpers.js
export const mockUser = {
  id: 1,
  email: 'test@example.com',
  fullName: 'Test User'
};

export const mockListing = {
  id: 1,
  title: 'Test Listing',
  price: 100,
  // ... other fields
};
```

---

## 📈 Success Metrics

### Minimum Viable Testing
- ✅ All P0 tests passing
- ✅ No critical bugs in tested flows
- ✅ Test coverage report generated
- ✅ Tests run in CI/CD pipeline

### Good Testing Coverage
- ✅ All P0 and P1 tests passing
- ✅ 60%+ backend service coverage
- ✅ 5+ E2E user flows tested
- ✅ Tests document expected behavior

---

## ⏱️ Time Estimates

| Phase | Task | Hours |
|-------|------|-------|
| Phase 1 | Backend Unit Tests | 6-8 |
| Phase 2 | Backend Integration Tests | 4-6 |
| Phase 3 | Frontend Unit Tests | 3-4 |
| Phase 4 | E2E Tests | 4-6 |
| **Total** | | **17-24 hours** |

**With Focus on P0 Only:** ~8-12 hours

---

## 🐛 Common Issues & Solutions

### Backend
- **Issue:** Tests fail due to database state
  - **Solution:** Use `@Transactional` and `@Rollback` annotations

- **Issue:** MockMvc not found
  - **Solution:** Add `spring-boot-starter-test` dependency

### Frontend
- **Issue:** Tests can't find React components
  - **Solution:** Check import paths, ensure components export correctly

- **Issue:** E2E tests fail due to timing
  - **Solution:** Use proper waits: `await page.waitForSelector()`

---

## 📚 Resources

- **JUnit 5:** https://junit.org/junit5/
- **Mockito:** https://site.mockito.org/
- **Spring Boot Testing:** https://spring.io/guides/gs/testing-web/
- **React Testing Library:** https://testing-library.com/react
- **Playwright:** https://playwright.dev/

---

**Note:** Start with P0 tests only. Expand to P1 if time permits. The goal is to have confidence in critical functionality, not 100% coverage.

