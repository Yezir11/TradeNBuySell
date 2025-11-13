import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Navigation from '../components/Navigation';
import './LandingPage.css';

const LandingPage = () => {
  const { isAuthenticated, loading } = useAuth();

  // Show loading state while validating token
  if (loading) {
    return (
      <div className="landing-page">
        <Navigation />
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '50vh' }}>
          <p>Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="landing-page">
      <Navigation />
      
      {/* Hero Section */}
      <section className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">
            Your Campus Marketplace
            <span className="highlight"> at BITS Pilani</span>
          </h1>
          <p className="hero-subtitle">
            Buy, sell, trade, and bid on items within the BITS Pilani community. 
            A secure, trusted platform exclusively for <span className="domain-badge">@pilani.bits-pilani.ac.in</span> students.
          </p>
          <div className="hero-cta">
            {!isAuthenticated ? (
              <Link to="/auth" className="cta-primary">
                Get Started <span className="arrow">→</span>
              </Link>
            ) : (
              <Link to="/marketplace" className="cta-primary">
                Explore Marketplace <span className="arrow">→</span>
              </Link>
            )}
            <Link to="/marketplace" className="cta-secondary">
              Browse Listings
            </Link>
          </div>
        </div>
        <div className="hero-visual">
          <div className="floating-card card-1">
            <div className="card-icon">🛍️</div>
            <p>Buy & Sell</p>
          </div>
          <div className="floating-card card-2">
            <div className="card-icon">🔄</div>
            <p>Trade Items</p>
          </div>
          <div className="floating-card card-3">
            <div className="card-icon">💰</div>
            <p>Virtual Wallet</p>
          </div>
          <div className="floating-card card-4">
            <div className="card-icon">💬</div>
            <p>Secure Chat</p>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <div className="container">
          <div className="section-header">
            <h2>Why Choose TradeNBuySell?</h2>
            <p className="section-subtitle">Everything you need for seamless campus trading</p>
          </div>
          
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">🛒</div>
              <h3>Buy & Sell</h3>
              <p>List items for sale or browse through hundreds of listings from fellow students. Find textbooks, electronics, furniture, and more.</p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">🔄</div>
              <h3>Trade System</h3>
              <p>Exchange items directly with other students. Propose trades with multiple items and optional cash adjustments.</p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">🎯</div>
              <h3>Bidding</h3>
              <p>Participate in competitive bidding on select items. Place bids, track your offers, and win auctions.</p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">💳</div>
              <h3>Virtual Wallet</h3>
              <p>Secure internal wallet system for all transactions. Start with ₹1000 credit and manage your balance seamlessly.</p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">⭐</div>
              <h3>Trust Scores</h3>
              <p>Built-in trust system based on transaction ratings. See seller credibility and build your reputation.</p>
            </div>
            
            <div className="feature-card">
              <div className="feature-icon">🔒</div>
              <h3>Secure & Private</h3>
              <p>End-to-end chat encryption, domain-restricted access, and comprehensive moderation for a safe experience.</p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="how-it-works-section">
        <div className="container">
          <div className="section-header">
            <h2>How It Works</h2>
            <p className="section-subtitle">Simple steps to start trading on campus</p>
          </div>
          
          <div className="steps-container">
            <div className="step">
              <div className="step-number">1</div>
              <div className="step-content">
                <h3>Create Your Account</h3>
                <p>Register with your @pilani.bits-pilani.ac.in email and set a secure password.</p>
              </div>
            </div>
            
            <div className="step">
              <div className="step-number">2</div>
              <div className="step-content">
                <h3>Verify Your Email</h3>
                <p>Your wallet is automatically credited with ₹1000 when you register.</p>
              </div>
            </div>
            
            <div className="step">
              <div className="step-number">3</div>
              <div className="step-content">
                <h3>Browse or List</h3>
                <p>Explore the marketplace for items you need, or create your first listing to start selling.</p>
              </div>
            </div>
            
            <div className="step">
              <div className="step-number">4</div>
              <div className="step-content">
                <h3>Trade & Transact</h3>
                <p>Make purchases, propose trades, place bids, or chat with sellers - all within our secure platform.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="stats-section">
        <div className="container">
          <div className="stats-grid">
            <div className="stat-item">
              <div className="stat-number">209+</div>
              <div className="stat-label">Active Listings</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">Secure</div>
              <div className="stat-label">Domain Restricted</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">₹1000</div>
              <div className="stat-label">Welcome Credit</div>
            </div>
            <div className="stat-item">
              <div className="stat-number">24/7</div>
              <div className="stat-label">Available</div>
            </div>
          </div>
        </div>
      </section>

      {/* Trust Section */}
      <section className="trust-section">
        <div className="container">
          <div className="trust-content">
            <div className="trust-text">
              <h2>A Trusted Platform</h2>
              <p>TradeNBuySell is designed exclusively for BITS Pilani students. With built-in moderation, trust scores, and secure transactions, you can trade with confidence.</p>
              <ul className="trust-features">
                <li>✓ Domain-restricted access (pilani.bits-pilani.ac.in only)</li>
                <li>✓ Comprehensive reporting and moderation system</li>
                <li>✓ Real-time transaction tracking</li>
                <li>✓ Secure wallet system with transaction history</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="cta-section">
        <div className="container">
          <div className="cta-content">
            <h2>Ready to Start Trading?</h2>
            <p>Join the BITS Pilani campus marketplace today</p>
            <div className="cta-buttons">
              {!isAuthenticated ? (
                <Link to="/auth" className="cta-primary-large">
                  Get Started Now <span className="arrow">→</span>
                </Link>
              ) : (
                <Link to="/marketplace" className="cta-primary-large">
                  Browse Marketplace <span className="arrow">→</span>
                </Link>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="landing-footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-brand">
              <h3>TradeNBuySell</h3>
              <p>Your Campus Marketplace</p>
            </div>
            <div className="footer-links">
              <div className="footer-column">
                <h4>Platform</h4>
                <Link to="/marketplace">Marketplace</Link>
                <Link to="/post-listing">Post Listing</Link>
                <Link to="/trades">Trades</Link>
                <Link to="/bids">Bids</Link>
              </div>
              <div className="footer-column">
                <h4>Account</h4>
                <Link to="/profile">My Profile</Link>
                <Link to="/wallet">Wallet</Link>
                <Link to="/chat">Messages</Link>
              </div>
              <div className="footer-column">
                <h4>About</h4>
                <p>BITS Pilani Exclusive</p>
                <p>Campus Marketplace</p>
                <p>Secure & Trusted</p>
              </div>
            </div>
          </div>
          <div className="footer-bottom">
            <p>&copy; 2025 TradeNBuySell. Built for BITS Pilani students.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;
