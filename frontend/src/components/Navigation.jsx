import React, { useState, useEffect } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import './Navigation.css';

const Navigation = () => {
  const { isAuthenticated, user, logout, isAdmin, loading } = useAuth();
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isUserDropdownOpen, setIsUserDropdownOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  // Don't show user dropdown if loading or no user
  const showUserDropdown = isAuthenticated && user && !loading;

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
    setIsUserDropdownOpen(false);
  };

  const toggleUserDropdown = () => {
    setIsUserDropdownOpen(!isUserDropdownOpen);
    setIsMobileMenuOpen(false);
  };

  // Fetch unread message count
  useEffect(() => {
    if (!isAuthenticated || !user || loading) {
      setUnreadCount(0);
      return;
    }

    const fetchUnreadCount = async () => {
      try {
        const response = await api.get('/api/chat/unread-count');
        setUnreadCount(response.data.unreadCount || 0);
      } catch (err) {
        console.error('Failed to fetch unread count:', err);
        setUnreadCount(0);
      }
    };

    fetchUnreadCount();
    // Poll every 10 seconds for new messages
    const interval = setInterval(fetchUnreadCount, 10000);
    return () => clearInterval(interval);
  }, [isAuthenticated, user, loading]);

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-brand">
          <img src="/navbar-logo.svg" alt="TradeNBuySell" className="navbar-logo" />
        </Link>

        <div className="menu-icon" onClick={toggleMobileMenu}>
          <i className={isMobileMenuOpen ? 'fas fa-times' : 'fas fa-bars'}></i>
        </div>

        <div className={`nav-links ${isMobileMenuOpen ? 'active' : ''}`}>
          <NavLink to="/marketplace" onClick={() => setIsMobileMenuOpen(false)}>Marketplace</NavLink>
          {!loading && isAuthenticated && user && (
            <>
              <NavLink to="/post-listing" onClick={() => setIsMobileMenuOpen(false)}>Post Listing</NavLink>
              <NavLink to="/trades" onClick={() => setIsMobileMenuOpen(false)}>Trades</NavLink>
              <NavLink to="/bids" onClick={() => setIsMobileMenuOpen(false)}>Bidding Center</NavLink>
              <NavLink to="/chat" onClick={() => setIsMobileMenuOpen(false)} className="chat-link">
                Chat
                {unreadCount > 0 && (
                  <span className="unread-badge">{unreadCount > 99 ? '99+' : unreadCount}</span>
                )}
              </NavLink>
              {isAdmin() && (
                <NavLink to="/admin" onClick={() => setIsMobileMenuOpen(false)}>Admin Dashboard</NavLink>
              )}
            </>
          )}
          {!loading && !isAuthenticated && (
            <NavLink to="/auth" onClick={() => setIsMobileMenuOpen(false)}>Login / Register</NavLink>
          )}

          {showUserDropdown && (
            <div className="user-dropdown">
              <div className="user-info" onClick={toggleUserDropdown}>
                <span>{user.fullName || user.email}</span>
                <i className="fas fa-caret-down"></i>
              </div>
              {isUserDropdownOpen && (
                <div className="dropdown-menu">
                  <Link to="/profile" onClick={() => { setIsUserDropdownOpen(false); setIsMobileMenuOpen(false); }}>My Profile</Link>
                  <Link to="/wallet" onClick={() => { setIsUserDropdownOpen(false); setIsMobileMenuOpen(false); }}>Wallet</Link>
                  <button onClick={handleLogout}>Logout</button>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navigation;

