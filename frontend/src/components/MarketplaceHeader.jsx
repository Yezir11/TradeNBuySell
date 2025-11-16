import React, { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import NotificationBell from './NotificationBell';
import './MarketplaceHeader.css';

const MarketplaceHeader = ({ showSearch = true, searchPlaceholder = "Find items, services and more...", onSearchSubmit, onSearchChange, initialSearchQuery = '' }) => {
  const { isAuthenticated, user, logout, isAdmin } = useAuth();
  const navigate = useNavigate();
  const [isUserDropdownOpen, setIsUserDropdownOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState(initialSearchQuery);
  const debounceTimerRef = useRef(null);

  // Update search query when initialSearchQuery changes (e.g., from URL params)
  useEffect(() => {
    setSearchQuery(initialSearchQuery);
  }, [initialSearchQuery]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (isUserDropdownOpen && !event.target.closest('.user-dropdown-wrapper')) {
        setIsUserDropdownOpen(false);
      }
    };

    if (isUserDropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => {
        document.removeEventListener('mousedown', handleClickOutside);
      };
    }
  }, [isUserDropdownOpen]);

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const toggleUserDropdown = () => {
    setIsUserDropdownOpen(!isUserDropdownOpen);
  };

  const handleSearchInputChange = (e) => {
    const value = e.target.value;
    setSearchQuery(value);

    // Clear previous debounce timer
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }

    // Debounce: wait 300ms after user stops typing before triggering search
    debounceTimerRef.current = setTimeout(() => {
      if (onSearchChange) {
        onSearchChange(value);
      } else if (onSearchSubmit) {
        onSearchSubmit(value);
      } else {
        // Default behavior: update URL
        if (value.trim()) {
          navigate(`/marketplace?search=${encodeURIComponent(value)}`);
        } else {
          navigate('/marketplace');
        }
      }
    }, 300);
  };

  const handleSearch = (e) => {
    e.preventDefault();
    // Clear debounce timer since we're submitting immediately
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }
    
    if (onSearchSubmit) {
      onSearchSubmit(searchQuery);
    } else if (onSearchChange) {
      onSearchChange(searchQuery);
    } else {
      if (searchQuery.trim()) {
        navigate(`/marketplace?search=${encodeURIComponent(searchQuery)}`);
      } else {
        navigate('/marketplace');
      }
    }
  };

  // Cleanup debounce timer on unmount
  useEffect(() => {
    return () => {
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }
    };
  }, []);

  return (
    <div className="marketplace-header">
      <div className="marketplace-header-container">
        <Link to="/" className="marketplace-logo">
          <img src="/navbar-logo.svg" alt="TradeNBuySell" className="marketplace-logo-img" />
        </Link>
        
        {showSearch && (
          <form className="marketplace-search-form" onSubmit={handleSearch}>
            <div className="search-bar-wrapper">
              <input
                type="text"
                className="marketplace-search-input"
                placeholder={searchPlaceholder}
                value={searchQuery}
                onChange={handleSearchInputChange}
              />
              <button type="submit" className="search-button">
                <i className="fas fa-search"></i>
              </button>
            </div>
          </form>
        )}

        <div className="marketplace-header-actions">
          {isAuthenticated ? (
            <>
              <Link to="/marketplace" className="marketplace-link-button">
                Marketplace
              </Link>
              <NotificationBell />
              <Link to="/chat" className="header-icon">
                <i className="fas fa-comments"></i>
              </Link>
              <div className="user-dropdown-wrapper">
                <button className="header-icon user-icon-button" onClick={toggleUserDropdown}>
                  <i className="fas fa-user"></i>
                </button>
                {isUserDropdownOpen && (
                  <div className="marketplace-dropdown-menu">
                    <Link to="/post-listing" onClick={() => setIsUserDropdownOpen(false)}>Post Listing</Link>
                    <Link to="/trades" onClick={() => setIsUserDropdownOpen(false)}>Trades</Link>
                    <Link to="/bids" onClick={() => setIsUserDropdownOpen(false)}>Bidding Center</Link>
                    {isAdmin() && (
                      <Link to="/admin" onClick={() => setIsUserDropdownOpen(false)}>Admin Dashboard</Link>
                    )}
                    <div className="dropdown-divider"></div>
                    <Link to="/profile" onClick={() => setIsUserDropdownOpen(false)}>My Profile</Link>
                    <Link to="/wallet" onClick={() => setIsUserDropdownOpen(false)}>Wallet</Link>
                    <button onClick={() => { handleLogout(); setIsUserDropdownOpen(false); }}>Logout</button>
                  </div>
                )}
              </div>
            </>
          ) : (
            <Link to="/auth" className="login-button">Login</Link>
          )}
        </div>
      </div>
    </div>
  );
};

export default MarketplaceHeader;

