# Git Workflow & Commit Organization Plan
## TradeNBuySell - Campus Marketplace Application

---

## 🌳 Branch Strategy

### Main Branches

1. **`main`** (Production-ready code)
   - Always stable and deployable
   - Protected branch (no direct commits)
   - Only merged via Pull Requests from `develop`

2. **`develop`** (Integration branch)
   - Main development branch
   - All feature branches merge here
   - Should be stable but may contain WIP features

### Supporting Branches

3. **`feature/*`** (New features)
   - Format: `feature/feature-name`
   - Examples:
     - `feature/user-authentication`
     - `feature/listing-pagination`
     - `feature/trade-system`
     - `feature/bidding-module`
     - `feature/chat-system`
     - `feature/admin-dashboard`

4. **`bugfix/*`** (Bug fixes)
   - Format: `bugfix/issue-description`
   - Examples:
     - `bugfix/login-error-persistence`
     - `bugfix/image-upload-error`
     - `bugfix/pagination-calculations`

5. **`hotfix/*`** (Critical production fixes)
   - Format: `hotfix/critical-issue`
   - Branches from `main`
   - Merges back to both `main` and `develop`

6. **`refactor/*`** (Code refactoring)
   - Format: `refactor/component-name`
   - Examples:
     - `refactor/auth-service`
     - `refactor/security-config`

---

## 📝 Commit Message Convention

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependencies, build config
- **perf**: Performance improvements
- **ci**: CI/CD changes

### Scope (Optional)
- `backend`: Backend changes
- `frontend`: Frontend changes
- `database`: Database schema/scripts
- `config`: Configuration files
- `auth`: Authentication related
- `api`: API endpoints
- `ui`: UI components

### Examples
```
feat(backend): Add user authentication with JWT tokens

- Implement JWT token generation and validation
- Add CustomUserDetailsService for Spring Security
- Create AuthController with login/register endpoints

feat(frontend): Implement marketplace with pagination

- Add Marketplace component with listing grid
- Implement pagination controls
- Add search and category filtering

fix(auth): Resolve error message disappearing issue

- Fix error state management in AuthPage
- Add proper error persistence logic
- Improve error message styling

refactor(backend): Simplify SecurityConfig

- Remove OAuth2 dependencies
- Clean up unused handlers
- Update security filter chain

docs: Add git workflow documentation

- Document branch strategy
- Add commit message conventions
- Include contribution guidelines
```

---

## 🗂️ Initial Commit Organization

### Phase 1: Project Setup & Core Infrastructure
**Branch**: `develop` (initial commit)

1. **Initial project structure**
   ```
   chore: Initialize project structure
   - Add backend Spring Boot project
   - Add frontend React project
   - Add basic configuration files
   ```

2. **Backend core setup**
   ```
   feat(backend): Set up Spring Boot application
   - Configure Maven dependencies
   - Set up application.properties
   - Create main application class
   ```

3. **Database schema**
   ```
   feat(database): Create database schema
   - Add schema.sql with all table definitions
   - Set up relationships and constraints
   ```

4. **Frontend core setup**
   ```
   feat(frontend): Initialize React application
   - Set up React Router
   - Configure Axios for API calls
   - Add basic project structure
   ```

### Phase 2: Authentication System
**Branch**: `feature/authentication`

5. **Backend authentication**
   ```
   feat(backend): Implement authentication system
   - Add User entity and repository
   - Create AuthService with login/register
   - Implement JWT token generation
   - Add SecurityConfig with JWT filter
   ```

6. **Frontend authentication**
   ```
   feat(frontend): Add authentication pages
   - Create AuthPage component
   - Implement login/register forms
   - Add AuthContext for state management
   - Create PrivateRoute component
   ```

7. **Domain validation**
   ```
   feat(backend): Add email domain restriction
   - Validate @pilani.bits-pilani.ac.in domain
   - Update AuthService domain checks
   ```

### Phase 3: Core Features
**Branch**: `feature/marketplace` (or separate branches per feature)

8. **Listings module**
   ```
   feat(backend): Implement listings API
   - Create Listing entity and repository
   - Add ListingService with CRUD operations
   - Implement pagination and search
   - Create ListingController endpoints
   ```

   ```
   feat(frontend): Build marketplace interface
   - Create Marketplace page with grid layout
   - Add listing cards with images
   - Implement pagination UI
   - Add search and filter functionality
   ```

9. **User profile & wallet**
   ```
   feat(backend): Add wallet system
   - Create WalletTransaction entity
   - Implement WalletService
   - Add wallet endpoints
   ```

   ```
   feat(frontend): Add profile and wallet pages
   - Create MyProfile component
   - Implement Wallet page with transactions
   - Add wallet balance display
   ```

10. **Trading system**
    ```
    feat(backend): Implement trade functionality
    - Create Trade entity and relationships
    - Add TradeService with trade logic
    - Create TradeController endpoints
    ```

    ```
    feat(frontend): Add trade center interface
    - Create TradeCenter page
    - Implement trade creation form
    - Add trade management UI
    ```

11. **Bidding system**
    ```
    feat(backend): Add bidding functionality
    - Create Bid entity
    - Implement BidService with auction logic
    - Add BidController endpoints
    ```

    ```
    feat(frontend): Build bidding interface
    - Create BiddingCenter page
    - Add bid placement UI
    - Implement bid history display
    ```

12. **Chat system**
    ```
    feat(backend): Implement messaging system
    - Create ChatMessage entity
    - Add ChatService for message handling
    - Create ChatController endpoints
    ```

    ```
    feat(frontend): Add chat interface
    - Create ChatPage component
    - Implement conversation list
    - Add message input and display
    ```

### Phase 4: Advanced Features

13. **Admin dashboard**
    ```
    feat(backend): Add admin functionality
    - Create AdminController
    - Implement report management
    - Add user management endpoints
    ```

    ```
    feat(frontend): Build admin dashboard
    - Create AdminDashboard page
    - Add reports management UI
    - Implement user management interface
    ```

14. **Ratings & trust scores**
    ```
    feat(backend): Implement rating system
    - Create Rating entity
    - Add trust score calculation
    - Create RatingService
    ```

15. **Reporting system**
    ```
    feat(backend): Add reporting functionality
    - Create Report entity
    - Implement ReportService
    - Add moderation endpoints
    ```

### Phase 5: UI/UX Improvements

16. **Navigation & layout**
    ```
    feat(frontend): Add navigation component
    - Create Navigation bar
    - Implement responsive design
    - Add role-based menu items
    ```

17. **Landing page**
    ```
    feat(frontend): Create landing page
    - Design hero section
    - Add features showcase
    - Implement responsive layout
    ```

18. **Styling & polish**
    ```
    style(frontend): Improve UI consistency
    - Add global CSS variables
    - Improve component styling
    - Add animations and transitions
    ```

### Phase 6: Bug Fixes & Refactoring

19. **Bug fixes**
    ```
    fix(auth): Resolve error message persistence
    fix(marketplace): Fix pagination calculations
    fix(backend): Fix user lookup by UUID
    fix(security): Update domain to .ac.in
    ```

20. **Refactoring**
    ```
    refactor(backend): Clean up SecurityConfig
    refactor(frontend): Optimize component structure
    refactor(database): Update domain in SQL scripts
    ```

---

## 📦 Recommended Initial Commit Structure

### Option A: Feature-Based Commits (Recommended)
Group commits by complete features:
- Each feature branch contains all related backend + frontend changes
- Easier to review and understand
- Better for collaboration

### Option B: Layer-Based Commits
Separate backend and frontend commits:
- Backend commits first
- Then frontend commits
- Good for clear separation of concerns

### Option C: Hybrid Approach (Best for this project)
- Major features as separate commits
- Related backend + frontend together
- Bug fixes and refactoring separate

---

## 🚀 Recommended Initial Commit Plan

For the **first push to GitHub**, I suggest:

1. **Initial commit** - Project structure
2. **Backend core** - All backend entities, repositories, services, controllers
3. **Frontend core** - All React components, pages, context
4. **Database** - Schema and migration scripts
5. **Configuration** - All config files, .gitignore
6. **Documentation** - README, this workflow doc

Then create feature branches for future work.

---

## ✅ What I'll Do

1. Create `.gitignore` (exclude build files, node_modules, etc.)
2. Initialize git repository
3. Create `develop` branch
4. Organize commits as per your preference
5. Push to your repository

**Which commit organization do you prefer?**
- A) Feature-based (all related code together)
- B) Layer-based (backend first, then frontend)
- C) Hybrid (major features together, rest separate)

Or would you like me to propose a specific commit breakdown based on the current codebase?

