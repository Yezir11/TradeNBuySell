import React, { useState } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import './Navigation.css';

const Navigation = () => {
  const { isAuthenticated, user, logout, isAdmin } = useAuth();
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isUserDropdownOpen, setIsUserDropdownOpen] = useState(false);

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

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-brand">
          TradeNBuySell
        </Link>

        <div className="menu-icon" onClick={toggleMobileMenu}>
          <i className={isMobileMenuOpen ? 'fas fa-times' : 'fas fa-bars'}></i>
        </div>

        <div className={`nav-links ${isMobileMenuOpen ? 'active' : ''}`}>
          <NavLink to="/marketplace" onClick={() => setIsMobileMenuOpen(false)}>Marketplace</NavLink>
          {isAuthenticated && (
            <>
              <NavLink to="/post-listing" onClick={() => setIsMobileMenuOpen(false)}>Post Listing</NavLink>
              <NavLink to="/trades" onClick={() => setIsMobileMenuOpen(false)}>Trades</NavLink>
              <NavLink to="/bids" onClick={() => setIsMobileMenuOpen(false)}>Bids</NavLink>
              <NavLink to="/chat" onClick={() => setIsMobileMenuOpen(false)}>Chat</NavLink>
              {isAdmin() && (
                <NavLink to="/admin" onClick={() => setIsMobileMenuOpen(false)}>Admin Dashboard</NavLink>
              )}
            </>
          )}
          {!isAuthenticated && (
            <NavLink to="/auth" onClick={() => setIsMobileMenuOpen(false)}>Login / Register</NavLink>
          )}

          {isAuthenticated && (
            <div className="user-dropdown">
              <div className="user-info" onClick={toggleUserDropdown}>
                <span>{user?.fullName || user?.email}</span>
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

